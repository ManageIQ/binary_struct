require "binary_struct/version"
require "enumerator"

class BinaryStruct
  SIZES = {
    'A'   => 1,   # String with trailing NULs and spaces removed
    'a'   => 1,   # String
    'B'   => nil, # Extract bits from each character (MSB first)
    'b'   => nil, # Extract bits from each character (LSB first)
    'C'   => 1,   # Extract a character as an unsigned integer
    'c'   => 1,   # Extract a character as a    signed integer
    'E'   => nil, # Treat sizeof(double) characters as a double in little-endian byte order
    'e'   => nil, # Treat sizeof(float)  characters as a float  in little-endian byte order
    'G'   => nil, # Treat sizeof(double) characters as a double in network       byte order
    'g'   => nil, # Treat sizeof(float)  characters as a float  in network       byte order
    'H'   => nil, # Extract hex nibbles from each character (most  significant first)
    'h'   => nil, # Extract hex nibbles from each character (least significant first)
    'I'   => 4,   # Treat sizeof(int) successive characters as an unsigned native integer
    'i'   => 4,   # Treat sizeof(int) successive characters as a    signed native integer
    'L'   => 4,   # Treat 4 successive characters as an unsigned native long integer
    'l'   => 4,   # Treat 4 successive characters as a    signed native long integer
    'M'   => 1,   # Extract a quoted printable string
    'm'   => 1,   # Extract a Base64 encoded string
    'N'   => 4,   # Treat 4 characters as an unsigned long  in network byte order
    'n'   => 2,   # Treat 2 characters as an unsigned short in network byte order
    'P'   => nil, # Treat sizeof(char *) characters as a pointer, and return len characters from the referenced location
    'p'   => nil, # Treat sizeof(char *) characters as a pointer to a null-terminated string
    'Q'   => 8,   # Treat 8 characters as an unsigned quad word (64 bits)
    'q'   => 8,   # Treat 8 characters as a    signed quad word (64 bits)
    'S'   => 2,   # Treat 2 successive characters as an unsigned short in native byte order
    's'   => 2,   # Treat 2 successive characters as a    signed short in native byte order
    'U'   => nil, # Extract UTF-8 characters as unsigned integers
    'u'   => nil, # Extract a UU-encoded string
    'V'   => 4,   # Treat 4 characters as an unsigned long  in little-endian byte order
    'v'   => 2,   # Treat 2 characters as an unsigned short in little-endian byte order
    'w'   => nil, # BER-compressed integer
    'X'   => -1,  # Skip backward one character
    'x'   => 1,   # Skip forward  one character
    'Z'   => 1,   # String with trailing NULs removed
  }

  STRING_FORMATS   = %w(A a M m u)
  ENDIAN_FORMATS   = %w(I i L l Q q S s)
  ENDIAN_MODIFIERS = %w(> <)
  MODIFIERS        = ENDIAN_MODIFIERS

  def initialize(definition = nil)
    self.definition = definition unless definition.nil?
  end

  def definition
    @definition
  end

  def definition=(value)
    if value.kind_of?(self.class)
      @definition = value.definition.dup
    else
      value = Array(value)
      self.class.validate_definition(value)
      @definition = value
    end
    @size = @decode_format = @decode_name = nil
  end

  def size
    @size ||= self.class.get_size(@definition)
  end

  def decode(data, num = 1)
    values = self.decode_to_array(data, num)
    return self.decoded_array_to_hash!(values) if num == 1

    result = []
    num.times { result << self.decoded_array_to_hash!(values) }
    return result
  end

  def decode_to_array(data, num = 1)
    raise ArgumentError, "data cannot be nil" if data.nil?
    @decode_format, @decode_names = self.class.prep_decode(@definition) if @decode_format.nil?
    format = (num == 1) ? @decode_format : @decode_format * num
    return data.unpack(format)
  end

  def decoded_array_to_hash!(array)
    hash = {}
    @decode_names.each do |k|
      v = array.shift
      next if k.nil?
      hash[k] = v
    end
    return hash
  end

  def encode(hash)
    return encode_hash(hash) unless hash.kind_of?(Array)

    data = ""
    hash.each { |h| data << self.encode_hash(h) }
    return data
  end

  def encode_hash(hash)
    data = ""
    @definition.each_slice(2) do |format, name|
      raise "member not found: #{name}" unless name.nil? || hash.has_key?(name)
      value = unless name.nil?
        hash[name]
      else
        STRING_FORMATS.include?(format[0, 1]) ? '0' : 0
      end
      data << [value].pack(format)
    end
    return data
  end

  def ==(other)
    self.definition == other.definition
  end

  def each(&block)
    self.definition.each_slice(2, &block)
  end

  #
  # Methods to handle the old style of calling
  #

  @@structs_by_definition = {}

  def self.clear_structs_by_definition_cache
    @@structs_by_definition.clear
  end

  def self.sizeof(definition)
    struct_by_definition(definition).size
  end

  def self.decode(data, definition)
    struct_by_definition(definition).decode(data)
  end

  def self.encode(hash, definition)
    struct_by_definition(definition).encode(hash)
  end

  private

  def self.struct_by_definition(definition)
    @@structs_by_definition[definition] ||= definition.kind_of?(self) ? definition : self.new(definition)
  end

  def self.validate_definition(definition)
    raise "definition must be an array of format/name pairs" if definition.empty? || definition.length % 2 != 0
    definition.each_slice(2) do |format, _|
      type, count = format[0, 1], format[1..-1]
      modifier, modcount = count[0, 1], count[1..-1]
      validate_definition_entry_type(type)
      if validate_definition_entry_modifier(modifier)
        validate_definition_endian_modifier(modifier, type)
        validate_definition_entry_count(modcount)
      else
        validate_definition_entry_count(count)
      end
    end
  end

  def self.validate_definition_entry_type(type)
    raise "unrecognized format: #{type}" unless SIZES.has_key?(type)
    raise "unsupported format: #{type}" if SIZES[type].nil?
    return true
  end

  def self.validate_definition_entry_count(count)
    return true if count.empty? || count == '*'

    begin
      count = Integer(count)
    rescue
      raise "unsupported count: #{count}"
    end
    raise "unsupported count: #{count}" if count < 0
  end

  def self.validate_definition_entry_modifier(modifier)
    return true if MODIFIERS.include? modifier
    false
  end

  def self.validate_definition_endian_modifier(modifier, type)
    if ENDIAN_MODIFIERS.include? modifier
      raise "unsupported type attribute #{type} for endian modifier #{modifier}" unless ENDIAN_FORMATS.include? type
      return true
    end
    false
  end

  def self.get_size(definition)
    size = 0
    definition.each_slice(2) do |format, _|
      type, count        = format[0, 1], format[1..-1]
      modifier, modcount = count[0, 1], count[1..-1]
      if validate_definition_entry_modifier(modifier)
        count = modcount.empty? ? 1 : modcount.to_i
      else
        count = count.empty? ? 1 : count.to_i
      end
      size += (count * SIZES[type])
    end
    size
  end

  def self.prep_decode(definition)
    formats = ""
    names = []
    definition.each_slice(2) do |format, name|
      formats << format
      names << name
    end
    return formats, names
  end
end

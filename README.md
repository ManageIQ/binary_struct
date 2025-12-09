# BinaryStruct

[![Gem Version](https://badge.fury.io/rb/binary_struct.svg)](http://badge.fury.io/rb/binary_struct)
[![CI](https://github.com/ManageIQ/binary_struct/actions/workflows/ci.yaml/badge.svg)](https://github.com/ManageIQ/binary_struct/actions/workflows/ci.yaml)

BinaryStruct is a class for dealing with binary structured data.  It simplifies
expressing what the binary structure looks like, with the ability to name the
parts.  Given this definition, it is easy to encode/decode the binary structure
from/to a Hash.

## Example Usage

As an example, we will show reading and writing a .gif header.  This example is
also in spec/gif_spec.rb.

### Create the structure definition

```ruby
gif_header = BinaryStruct.new([
  "a3", :magic,
  "a3", :version,
  "S",  :width,
  "S",  :height,
  "a",  :flags,
  "C",  :bg_color_index,
  "C",  :pixel_aspect_ratio
])
```

### Read the header

```ruby
header_size = gif_header.size
header = File.open("test.gif", "rb") { |f| f.read(header_size) }
gif_header.decode(header)

=> {
  :magic              => "GIF",
  :version            => "89a",
  :width              => 16,
  :height             => 16,
  :flags              => "\x80",
  :bg_color_index     => 0,
  :pixel_aspect_ratio => 0
}
```

### Write the header

```ruby
header = gif_header.encode({
  :magic              => "GIF",
  :version            => "89a",
  :width              => 16,
  :height             => 16,
  :flags              => "\x80",
  :bg_color_index     => 0,
  :pixel_aspect_ratio => 0
})
File.open("test.gif", "wb") { |f| f.write(header) }

=> "GIF89a\x10\x00\x10\x00\x80\x00\x00"
```

## Note about bit and nibble formats

BinaryStruct supports bit formats and nibble formats, however note that the
underlying Ruby methods, [pack](http://ruby-doc.org/core-2.2.0/Array.html#method-i-pack)
and [unpack](http://ruby-doc.org/core-2.2.0/String.html#method-i-unpack), support
less than 8 bits by reading an entire byte, even if all of the bits are not used.

For example,

```ruby
s = "\xFF\x00"       # binary: 1111111100000000
s.unpack("b8b8")     # => ["11111111", "00000000"]
s.unpack("b4b4b4b4") # => ["1111", "0000", "", ""]
```

One might expect that the latter would read 4 bits, then the next 4 bits, etc,
yielding `["1111", "1111", "0000", "0000"]`, but that is not the case.  Instead,
the first b4 reads a full byte's worth, then discards the unused 4 bits, and the
same happens for the next b4.  The third and fourth b4 have nothing left to read,
and so just return empty strings.

## Installation

Add this line to your application's Gemfile:

    gem 'binary_struct'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install binary_struct

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

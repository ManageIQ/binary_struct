describe BinaryStruct do
  STRUCT_DEF = [
    'Q',  :quad,
    'L',  'long',
    'S',  :short,
    'C',  nil,
    'b5', :binary,
    'a0', 'none',
    'a',  nil,
    'a2', 'bc',
  ]
  STRUCT_DEF_SIZE = 19

  STRUCT_DEF_ASTERISK = ['a*', :word]
  STRUCT_DEF_ASTERISK_SIZE = 0 # '*' is ignored

  STRUCT_DEF_UNRECOGNIZED_FORMAT   = ['D', nil]
  STRUCT_DEF_UNSUPPORTED_FORMAT    = ['U', nil]
  STRUCT_DEF_UNSUPPORTED_COUNT_NEG = ['a-1', nil]
  STRUCT_DEF_UNSUPPORTED_COUNT_INV = ['aX', nil]

  STRUCT_ENCODED_STR  = "\000\111\222\333\444\555\666\777\000\111\222\333\000\111\000\0320BC".force_encoding("ASCII-8BIT")
  STRUCT_DECODED_HASH = {
    :quad   => 18_426_034_930_503_010_560,
    "long"  => 3_683_797_248,
    :short  => 18_688,
    :binary => "01011",
    "bc"    => "BC",
    "none"  => ""
  }

  it('.new') { expect { BinaryStruct.new }.not_to raise_error }
  it('.new with definition') { expect { BinaryStruct.new(STRUCT_DEF) }.not_to raise_error }
  it('.new with definition with *') { expect { BinaryStruct.new(STRUCT_DEF_ASTERISK) }.not_to raise_error }
  it '.new with another BinaryStruct' do
    s = BinaryStruct.new(STRUCT_DEF)
    s2 = BinaryStruct.new(s)
    expect(s2).to eq(s)
    expect(s2).not_to equal(s)
  end

  it('.new with unrecognized format')        { expect { BinaryStruct.new(STRUCT_DEF_UNRECOGNIZED_FORMAT) }.to   raise_error(RuntimeError) }
  it('.new with unsupported format')         { expect { BinaryStruct.new(STRUCT_DEF_UNSUPPORTED_FORMAT) }.to    raise_error(RuntimeError) }
  it('.new with unsupported negative count') { expect { BinaryStruct.new(STRUCT_DEF_UNSUPPORTED_COUNT_NEG) }.to raise_error(RuntimeError) }
  it('.new with unsupported invalid count')  { expect { BinaryStruct.new(STRUCT_DEF_UNSUPPORTED_COUNT_INV) }.to raise_error(RuntimeError) }

  it('#definition=') { expect { BinaryStruct.new.definition = STRUCT_DEF }.not_to raise_error }
  it('#definition= with definition with *') { expect { BinaryStruct.new.definition = STRUCT_DEF_ASTERISK }.not_to raise_error }

  it('#definition= with unrecognized format')        { expect { BinaryStruct.new.definition = STRUCT_DEF_UNRECOGNIZED_FORMAT }.to   raise_error(RuntimeError) }
  it('#definition= with unsupported format')         { expect { BinaryStruct.new.definition = STRUCT_DEF_UNSUPPORTED_FORMAT }.to    raise_error(RuntimeError) }
  it('#definition= with unsupported negative count') { expect { BinaryStruct.new.definition = STRUCT_DEF_UNSUPPORTED_COUNT_NEG }.to raise_error(RuntimeError) }
  it('#definition= with unsupported invalid count')  { expect { BinaryStruct.new.definition = STRUCT_DEF_UNSUPPORTED_COUNT_INV }.to raise_error(RuntimeError) }

  it('#size') { expect(BinaryStruct.new(STRUCT_DEF).size).to eq(STRUCT_DEF_SIZE) }
  it('#size with definition with *') { expect(BinaryStruct.new(STRUCT_DEF_ASTERISK).size).to eq(STRUCT_DEF_ASTERISK_SIZE) }

  it '#decode' do
    expect(BinaryStruct.new(STRUCT_DEF).decode(STRUCT_ENCODED_STR)).to eq(STRUCT_DECODED_HASH)
  end

  it '#decode with definition with *' do
    expect(BinaryStruct.new(STRUCT_DEF_ASTERISK).decode("Testing")).to eq(:word => "Testing")
  end

  it '#decode against multiple records' do
    expect(BinaryStruct.new(STRUCT_DEF).decode(STRUCT_ENCODED_STR * 10, 10)).to eq([STRUCT_DECODED_HASH] * 10)
  end

  it '#encode' do
    expect(BinaryStruct.new(STRUCT_DEF).encode(STRUCT_DECODED_HASH)).to eq(STRUCT_ENCODED_STR.force_encoding("ASCII-8BIT"))
  end

  it '#encode with definition with *' do
    expect(BinaryStruct.new(STRUCT_DEF_ASTERISK).encode(:word => "Testing")).to eq("Testing")
  end

  it '#encode against multiple records' do
    s = BinaryStruct.new(STRUCT_DEF).encode([STRUCT_DECODED_HASH] * 10)
    expect(s).to eq(STRUCT_ENCODED_STR.force_encoding("ASCII-8BIT") * 10)
  end

  it '#== against another BinaryStruct' do
    expect(BinaryStruct.new(STRUCT_DEF)).to     eq(BinaryStruct.new(STRUCT_DEF))
    expect(BinaryStruct.new(STRUCT_DEF)).not_to eq(BinaryStruct.new(STRUCT_DEF_ASTERISK))
  end

  it '#each will iterate over definition' do
    dup_def = []
    BinaryStruct.new(STRUCT_DEF).each { |field, name| dup_def << field << name }
    expect(dup_def).to eq(STRUCT_DEF)
  end

  context "old style methods" do
    after(:each) { BinaryStruct.clear_structs_by_definition_cache }

    it '#sizeof' do
      expect(BinaryStruct.sizeof(STRUCT_DEF)).to eq(STRUCT_DEF_SIZE)
      # Do it twice for consistency reasons
      expect(BinaryStruct.sizeof(STRUCT_DEF)).to eq(STRUCT_DEF_SIZE)
    end

    it '#decode' do
      expect(BinaryStruct.decode(STRUCT_ENCODED_STR, STRUCT_DEF)).to eq(STRUCT_DECODED_HASH)
      # Do it twice for consistency reasons
      expect(BinaryStruct.decode(STRUCT_ENCODED_STR, STRUCT_DEF)).to eq(STRUCT_DECODED_HASH)
    end

    it '#encode' do
      expect(BinaryStruct.encode(STRUCT_DECODED_HASH, STRUCT_DEF)).to eq(STRUCT_ENCODED_STR.force_encoding("ASCII-8BIT"))
      # Do it twice for consistency reasons
      expect(BinaryStruct.encode(STRUCT_DECODED_HASH, STRUCT_DEF)).to eq(STRUCT_ENCODED_STR.force_encoding("ASCII-8BIT"))
    end
  end
end

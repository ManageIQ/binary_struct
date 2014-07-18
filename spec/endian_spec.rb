describe BinaryStruct do
  BIG_STRUCT_DEF = [
    'Q>',  :quad,
    'L>',  'long',
    'S>',  :short,
    'C',   nil,
    'a0',  'none',
    'a',   nil,
    'a2',  'bc',
  ]
  BIG_STRUCT_DEF_SIZE                         = 18

  BIG_E_QUAD_STRUCT_DEF                       = ['Q>2',  :quad]
  BIG_E_QUAD_DEF_SIZE                         = 16

  BIG_STRUCT_DEF_STAR                         = ['i>*', :word]
  BIG_STRUCT_DEF_STAR_SIZE                    = 0 # '*' is ignored

  BIG_STRUCT_DEF_UNRECOG_ENDIAN_FMT           = ['Y>', nil]
  BIG_STRUCT_DEF_UNSUPPORTED_ENDIAN_ATTRIBUTE = ['A>', nil]
  BIG_STRUCT_DEF_INVALID_ENDIAN_MODIFIER      = ['Q_', nil]

  LIL_STRUCT_DEF = [
    'Q<',  :quad,
    'L<',  'long',
    'S<',  :short,
    'C',   nil,
    'a0',  'none',
    'a',   nil,
    'a2',  'bc',
  ]
  LIL_STRUCT_DEF_SIZE                         = 18

  LIL_E_QUAD_STRUCT_DEF                       = ['Q<2',  :quad]
  LIL_E_QUAD_DEF_SIZE                         = 16

  LIL_STRUCT_DEF_STAR                         = ['i<*', :word]
  LIL_STRUCT_DEF_STAR_SIZE                    = 0 # '*' is ignored

  LIL_STRUCT_DEF_UNRECOG_ENDIAN_FMT           = ['Y<', nil]
  LIL_STRUCT_DEF_UNSUPPORTED_ENDIAN_ATTRIBUTE = ['A<', nil]

  END_STRUCT_ENCODED_STR         = "\000\111\222\333\444\555\666\777\000\111\222\333\000\111\0000BC"

  LIL_ENDIAN_STRUCT_DECODED_HASH = {:quad  => 18_426_034_930_503_010_560,
                                    "long" => 3_683_797_248,
                                    :short => 18_688,
                                    "bc"   => "BC",
                                    "none" => ""}
  BIG_ENDIAN_STRUCT_DECODED_HASH = {:quad  => 20_709_143_206_541_055,
                                    "long" => 4_821_723,
                                    :short => 73,
                                    "none" => "",
                                    "bc"   => "BC"}

  it('.new') { expect { BinaryStruct.new }.not_to raise_error }
  it('.new with big definition') { expect { BinaryStruct.new(BIG_STRUCT_DEF) }.not_to raise_error }
  it('.new with little definition') { expect { BinaryStruct.new(LIL_STRUCT_DEF) }.not_to raise_error }
  it('.new with big definition with *') { expect { BinaryStruct.new(BIG_STRUCT_DEF_STAR) }.not_to raise_error }
  it('.new with little definition with *') { expect { BinaryStruct.new(LIL_STRUCT_DEF_STAR) }.not_to raise_error }
  it '.new with another big endian BinaryStruct' do
    s = BinaryStruct.new(BIG_STRUCT_DEF)
    s2 = BinaryStruct.new(s)
    expect(s2).to eq(s)
    expect(s2).not_to equal(s)
  end

  it '.new with another little endian BinaryStruct' do
    s = BinaryStruct.new(LIL_STRUCT_DEF)
    s2 = BinaryStruct.new(s)
    expect(s2).to eq(s)
    expect(s2).not_to equal(s)
  end

  it '.new big endian BinaryStruct with a little endian one' do
    s = BinaryStruct.new(BIG_STRUCT_DEF)
    s2 = BinaryStruct.new(LIL_STRUCT_DEF)
    expect(s2).not_to eq(s)
    expect(s2).not_to equal(s)
  end

  it('.new with unrecognized big e format') do
    expect { BinaryStruct.new(BIG_STRUCT_DEF_UNRECOG_ENDIAN_FMT) }
      .to raise_error(RuntimeError)
  end

  it('.new with unsupported big e attribute') do
    expect { BinaryStruct.new(BIG_STRUCT_DEF_UNSUPPORTED_ENDIAN_ATTRIBUTE) }
      .to raise_error(RuntimeError)
  end

  it('.new with invalid endian modifier') do
    expect { BinaryStruct.new(BIG_STRUCT_DEF_INVALID_ENDIAN_MODIFIER) }
      .to raise_error(RuntimeError)
  end

  it('.new with unrecognized little e format') do
    expect { BinaryStruct.new(LIL_STRUCT_DEF_UNRECOG_ENDIAN_FMT) }
      .to raise_error(RuntimeError)
  end

  it('.new with unsupported little e attribute') do
    expect { BinaryStruct.new(LIL_STRUCT_DEF_UNSUPPORTED_ENDIAN_ATTRIBUTE) }
      .to raise_error(RuntimeError)
  end

  it('#definition= with definition with *') do
    expect { BinaryStruct.new.definition = BIG_STRUCT_DEF_STAR }
      .not_to raise_error
  end

  it('#definition= with unrecognized big e format') do
    expect { BinaryStruct.new.definition = BIG_STRUCT_DEF_UNRECOG_ENDIAN_FMT }
      .to raise_error(RuntimeError)
  end
  it('#definition= with unsupported big e attribute') do
    expect { BinaryStruct.new.definition = BIG_STRUCT_DEF_UNSUPPORTED_ENDIAN_ATTRIBUTE }
      .to raise_error(RuntimeError)
  end
  it('#definition= with unrecognized little e format') do
    expect { BinaryStruct.new.definition = LIL_STRUCT_DEF_UNRECOG_ENDIAN_FMT }
      .to raise_error(RuntimeError)
  end
  it('#definition= with unsupported little e attribute') do
    expect { BinaryStruct.new.definition = LIL_STRUCT_DEF_UNSUPPORTED_ENDIAN_ATTRIBUTE }
      .to raise_error(RuntimeError)
  end

  it('#size') { expect(BinaryStruct.new(BIG_STRUCT_DEF).size).to eq(BIG_STRUCT_DEF_SIZE) }
  it('#size') { expect(BinaryStruct.new(LIL_STRUCT_DEF).size).to eq(LIL_STRUCT_DEF_SIZE) }
  it('#size with definition with *') { expect(BinaryStruct.new(BIG_STRUCT_DEF_STAR).size).to eq(BIG_STRUCT_DEF_STAR_SIZE) }
  it('#size with definition with *') { expect(BinaryStruct.new(LIL_STRUCT_DEF_STAR).size).to eq(LIL_STRUCT_DEF_STAR_SIZE) }

  it '#decode with different endian definitions' do
    expect(BinaryStruct.new(BIG_STRUCT_DEF).decode(END_STRUCT_ENCODED_STR))
      .not_to equal(BinaryStruct.new(LIL_STRUCT_DEF).decode(END_STRUCT_ENCODED_STR))
  end
  it '#encode with different endian definitions' do
    big    = BinaryStruct.new(BIG_STRUCT_DEF).encode(BIG_ENDIAN_STRUCT_DECODED_HASH)
    little = BinaryStruct.new(LIL_STRUCT_DEF).encode(LIL_ENDIAN_STRUCT_DECODED_HASH)
    expect(big).not_to equal(little)
  end

  it '#decode little endian struct' do
    expect(BinaryStruct.new(LIL_STRUCT_DEF).decode(END_STRUCT_ENCODED_STR)).to eq(LIL_ENDIAN_STRUCT_DECODED_HASH)
  end
  it '#decode big endian struct' do
    expect(BinaryStruct.new(BIG_STRUCT_DEF).decode(END_STRUCT_ENCODED_STR)).to eq(BIG_ENDIAN_STRUCT_DECODED_HASH)
  end

  it '#== against another little endian BinaryStruct' do
    expect(BinaryStruct.new(LIL_STRUCT_DEF)).to     eq(BinaryStruct.new(LIL_STRUCT_DEF))
  end
  it '#== big endian against another little endian BinaryStruct' do
    expect(BinaryStruct.new(BIG_STRUCT_DEF)).not_to eq(BinaryStruct.new(LIL_STRUCT_DEF))
  end
  it '#== against another big endian BinaryStruct' do
    expect(BinaryStruct.new(BIG_STRUCT_DEF)).to     eq(BinaryStruct.new(BIG_STRUCT_DEF))
  end

  it '#each will iterate over definition' do
    dup_def = []
    BinaryStruct.new(BIG_STRUCT_DEF).each { |field, name| dup_def << field << name }
    expect(dup_def).to eq(BIG_STRUCT_DEF)
  end

  it '#each will iterate over definition' do
    dup_def = []
    BinaryStruct.new(LIL_STRUCT_DEF).each { |field, name| dup_def << field << name }
    expect(dup_def).to eq(LIL_STRUCT_DEF)
  end

  context "old style methods" do
    after(:each) { BinaryStruct.clear_structs_by_definition_cache }

    it '#sizeof' do
      expect(BinaryStruct.sizeof(BIG_STRUCT_DEF)).to eq(BIG_STRUCT_DEF_SIZE)
    end
    # Do it twice for consistency reasons
    it '#sizeof' do
      expect(BinaryStruct.sizeof(BIG_STRUCT_DEF)).to eq(BIG_STRUCT_DEF_SIZE)
    end

    it '#sizeof' do
      expect(BinaryStruct.sizeof(LIL_STRUCT_DEF)).to eq(LIL_STRUCT_DEF_SIZE)
    end
    # Do it twice for consistency reasons
    it '#sizeof' do
      expect(BinaryStruct.sizeof(LIL_STRUCT_DEF)).to eq(LIL_STRUCT_DEF_SIZE)
    end
  end
end

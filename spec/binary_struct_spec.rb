require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

require 'binary_struct'

describe BinaryStruct do
  STRUCT_DEF = [
    'Q', :quad,
    'L', 'long',
    'S', :short,
    'C', nil,
    'a0', 'none',
    'a', nil,
    'a2', 'bc',
  ]
  STRUCT_DEF_SIZE = 18

  STRUCT_DEF_ASTERISK = ['a*', :word]
  STRUCT_DEF_ASTERISK_SIZE = 0 # '*' is ignored

  STRUCT_DEF_UNRECOGNIZED_FORMAT   = ['D', nil]
  STRUCT_DEF_UNSUPPORTED_FORMAT    = ['B', nil]
  STRUCT_DEF_UNSUPPORTED_COUNT_NEG = ['a-1', nil]
  STRUCT_DEF_UNSUPPORTED_COUNT_INV = ['aX', nil]

  STRUCT_ENCODED_STR  = "\000\111\222\333\444\555\666\777\000\111\222\333\000\111\0000BC"
  STRUCT_DECODED_HASH = {:quad=>18426034930503010560, "long"=>3683797248, :short=>18688, "bc"=>"BC", "none"=>""}

  it('.new') { lambda { BinaryStruct.new }.should_not raise_error }
  it('.new with definition') { lambda { BinaryStruct.new(STRUCT_DEF) }.should_not raise_error }
  it('.new with definition with *') { lambda { BinaryStruct.new(STRUCT_DEF_ASTERISK) }.should_not raise_error }
  it '.new with another BinaryStruct' do
    s = BinaryStruct.new(STRUCT_DEF)
    s2 = BinaryStruct.new(s)
    s2.should == s
    s2.should_not equal(s)
  end

  it('.new with unrecognized format')        { lambda { BinaryStruct.new(STRUCT_DEF_UNRECOGNIZED_FORMAT) }.should   raise_error(RuntimeError) }
  it('.new with unsupported format')         { lambda { BinaryStruct.new(STRUCT_DEF_UNSUPPORTED_FORMAT) }.should    raise_error(RuntimeError) }
  it('.new with unsupported negative count') { lambda { BinaryStruct.new(STRUCT_DEF_UNSUPPORTED_COUNT_NEG) }.should raise_error(RuntimeError) }
  it('.new with unsupported invalid count')  { lambda { BinaryStruct.new(STRUCT_DEF_UNSUPPORTED_COUNT_INV) }.should raise_error(RuntimeError) }

  it('#definition=') { lambda { BinaryStruct.new.definition = STRUCT_DEF }.should_not raise_error }
  it('#definition= with definition with *') { lambda { BinaryStruct.new.definition = STRUCT_DEF_ASTERISK }.should_not raise_error }

  it('#definition= with unrecognized format')        { lambda { BinaryStruct.new.definition = STRUCT_DEF_UNRECOGNIZED_FORMAT }.should   raise_error(RuntimeError) }
  it('#definition= with unsupported format')         { lambda { BinaryStruct.new.definition = STRUCT_DEF_UNSUPPORTED_FORMAT }.should    raise_error(RuntimeError) }
  it('#definition= with unsupported negative count') { lambda { BinaryStruct.new.definition = STRUCT_DEF_UNSUPPORTED_COUNT_NEG }.should raise_error(RuntimeError) }
  it('#definition= with unsupported invalid count')  { lambda { BinaryStruct.new.definition = STRUCT_DEF_UNSUPPORTED_COUNT_INV }.should raise_error(RuntimeError) }

  it('#size') { BinaryStruct.new(STRUCT_DEF).size.should == STRUCT_DEF_SIZE }
  it('#size with definition with *') { BinaryStruct.new(STRUCT_DEF_ASTERISK).size.should == STRUCT_DEF_ASTERISK_SIZE }

  it '#decode' do
    BinaryStruct.new(STRUCT_DEF).decode(STRUCT_ENCODED_STR).should == STRUCT_DECODED_HASH
  end

  it '#decode with definition with *' do
    BinaryStruct.new(STRUCT_DEF_ASTERISK).decode("Testing").should == {:word => "Testing"}
  end

  it '#decode against multiple records' do
    BinaryStruct.new(STRUCT_DEF).decode(STRUCT_ENCODED_STR * 10, 10).should == [STRUCT_DECODED_HASH] * 10
  end

  it '#encode' do
    BinaryStruct.new(STRUCT_DEF).encode(STRUCT_DECODED_HASH).should == STRUCT_ENCODED_STR
  end

  it '#encode with definition with *' do
    BinaryStruct.new(STRUCT_DEF_ASTERISK).encode({:word => "Testing"}).should == "Testing"
  end

  it '#encode against multiple records' do
    BinaryStruct.new(STRUCT_DEF).encode([STRUCT_DECODED_HASH] * 10).should == (STRUCT_ENCODED_STR * 10)
  end

  it '#== against another BinaryStruct' do
    BinaryStruct.new(STRUCT_DEF).should     == BinaryStruct.new(STRUCT_DEF)
    BinaryStruct.new(STRUCT_DEF).should_not == BinaryStruct.new(STRUCT_DEF_ASTERISK)
  end

  it '#each will iterate over definition' do
    dup_def = []
    BinaryStruct.new(STRUCT_DEF).each { |field, name| dup_def << field << name }
    dup_def.should == STRUCT_DEF
  end

  context "old style methods" do
    after(:each) { BinaryStruct.clear_structs_by_definition_cache }

    it '#sizeof' do
      BinaryStruct.sizeof(STRUCT_DEF).should == STRUCT_DEF_SIZE
      # Do it twice for consistency reasons
      BinaryStruct.sizeof(STRUCT_DEF).should == STRUCT_DEF_SIZE
    end

    it '#decode' do
      BinaryStruct.decode(STRUCT_ENCODED_STR, STRUCT_DEF).should == STRUCT_DECODED_HASH
      # Do it twice for consistency reasons
      BinaryStruct.decode(STRUCT_ENCODED_STR, STRUCT_DEF).should == STRUCT_DECODED_HASH
    end

    it '#encode' do
      BinaryStruct.encode(STRUCT_DECODED_HASH, STRUCT_DEF).should == STRUCT_ENCODED_STR
      # Do it twice for consistency reasons
      BinaryStruct.encode(STRUCT_DECODED_HASH, STRUCT_DEF).should == STRUCT_ENCODED_STR
    end
  end
end
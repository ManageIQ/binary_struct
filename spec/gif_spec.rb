require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

require 'binary_struct'

describe BinaryStruct do
  let(:gif_header) do
    BinaryStruct.new([
      "a3", :magic,
      "a3", :version,
      "S",  :width,
      "S",  :height,
      "a",  :flags,
      "C",  :bg_color_index,
      "C",  :pixel_aspect_ratio
    ])
  end

  it "read a gif header" do
    filename = File.join(File.dirname(__FILE__), %w(data test.gif))
    decoded_header_hash = {
      :magic              => "GIF",
      :version            => "89a",
      :width              => 16,
      :height             => 16,
      :flags              => "\x80",
      :bg_color_index     => 0,
      :pixel_aspect_ratio => 0,
    }
    encoded_header = gif_header.encode(decoded_header_hash)
    header_size = gif_header.size
    header = File.open(filename, "rb") { |f| f.read(header_size) }
    encoded_header.should == header
  end

  it "write a gif header" do
    header = gif_header.encode(
      :magic              => "GIF",
      :version            => "89a",
      :width              => 16,
      :height             => 16,
      :flags              => "\x80",
      :bg_color_index     => 0,
      :pixel_aspect_ratio => 0
    )

    header.should == "GIF89a\x10\x00\x10\x00\x80\x00\x00".force_encoding("ASCII-8BIT")
  end
end

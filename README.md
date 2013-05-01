# BinaryStruct

[![Gem Version](https://badge.fury.io/rb/binary_struct.png)](http://badge.fury.io/rb/binary_struct)
[![Build Status](https://travis-ci.org/ManageIQ/binary_struct.png)](https://travis-ci.org/ManageIQ/binary_struct)
[![Code Climate](https://codeclimate.com/github/ManageIQ/binary_struct.png)](https://codeclimate.com/github/ManageIQ/binary_struct)
[![Coverage Status](https://coveralls.io/repos/ManageIQ/binary_struct/badge.png?branch=master)](https://coveralls.io/r/ManageIQ/binary_struct)
[![Dependency Status](https://gemnasium.com/ManageIQ/binary_struct.png)](https://gemnasium.com/ManageIQ/binary_struct)

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

require 'fluent/plugin/gappedmultiline'
require 'fluent/test'
require 'fluent/test/helpers'

class Test::Unit::TestCase
  def create_driver conf = {}
    conf = {'format1' => '/(?<first>first_line)/'}.merge(conf)
    Fluent::Test::ParserTestDriver.new(Fluent::TextParser::GappedMultilineParser).configure(conf)
  end

  def setup
    Fluent::Test.setup
    @driver = create_driver
  end
end

class Fluent::Test::ParserTestDriver
  def has_firstline?
    @instance.has_firstline?
  end

  def firstline? line, formats
    @instance.firstline?(line, formats)
  end
end

include Fluent::Test::Helpers

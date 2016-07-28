require_relative 'helper'
require 'fluent/test/driver/parser'
require 'fluent/plugin/parser'
require 'pry'

class MultilineParserTest < ::Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_parser(conf)
    parser = Fluent::Test::ParserTestDriver.new(Fluent::TextParser::GappedMultilineParser).configure(conf)
    parser
  end

  def test_configure_with_invalid_params
    [{'format100' => '/(?<msg>.*)/'}, {'format1' => '/(?<msg>.*)/', 'format3' => '/(?<msg>.*)/'}, 'format1' => '/(?<msg>.*)'].each { |config|
      assert_raise(Fluent::ConfigError) {
        create_parser(config)
      }
    }
  end

  def test_parse_with_multiple_formats
    parser = create_parser('format_firstline' => '/^Started/',
                           'format1' => '/Started (?<method>[^ ]+) "(?<path>[^"]+)" for (?<host>[^ ]+) at (?<time>[^ ]+ [^ ]+ [^ ]+)\n/',
                           'format2' => '/Processing by (?<controller>[^\u0023]+)\u0023(?<controller_method>[^ ]+) as (?<format>[^ ]+?)\n/',
                           'format3' => '/(  Parameters: (?<parameters>[^ ]+)\n)?/',
                           'format4' => '/  Rendered (?<template>[^ ]+) within (?<layout>.+) \([\d\.]+ms\)\n/',
                           'format5' => '/Completed (?<code>[^ ]+) [^ ]+ in (?<runtime>[\d\.]+)ms \(Views: (?<view_runtime>[\d\.]+)ms \| ActiveRecord: (?<ar_runtime>[\d\.]+)ms\)/'
                           )
    parser.instance.parse(<<EOS.chomp) { |time, record|
Started GET "/users/123/" for 127.0.0.1 at 2013-06-14 12:00:11 +0900
Processing by UsersController#show as HTML
  Parameters: {"user_id"=>"123"}
  Rendered users/show.html.erb within layouts/application (0.3ms)
Completed 200 OK in 4ms (Views: 3.2ms | ActiveRecord: 0.0ms)
EOS

      assert(parser.instance.firstline?('Started GET "/users/123/" for 127.0.0.1...'))
#      assert_equal(event_time('2013-06-14 12:00:11 +0900').to_i, time)
#      assert_equal({
#                     "method" => "GET",
#                     "path" => "/users/123/",
#                     "host" => "127.0.0.1",
#                     "controller" => "UsersController",
#                     "controller_method" => "show",
#                     "format" => "HTML",
#                     "parameters" => "{\"user_id\"=>\"123\"}",
#                     "template" => "users/show.html.erb",
#                     "layout" => "layouts/application",
#                     "code" => "200",
#                     "runtime" => "4",
#                     "view_runtime" => "3.2",
#                     "ar_runtime" => "0.0"
#                   }, record)
    }
  end
end

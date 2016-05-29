require 'helper'

class Fluent::TextParser::GappedMultilineParserTest < Test::Unit::TestCase
  test '#has_firstline?' do
    assert_equal(true, @driver.has_firstline?)
  end

  test '#firstline?' do
    formats = [/\Athis_is_a_firstline\z/, /\Athis_is_a_secondline\z/]
    assert_equal(true,  @driver.firstline?('this_is_a_firstline', formats))
    assert_equal(false, @driver.firstline?('this_is_a_firstline!', formats))
    assert_equal(false, @driver.firstline?('hi, this_is_a_firstline', formats))
    assert_equal(false, @driver.firstline?('this_is_a_secondline', formats))
  end

  sub_test_case 'configure' do
    sub_test_case 'perser_buffer_limit' do
      test 'default value' do
        assert_equal(1000, @driver.instance.parser_buffer_limit)
      end

      test 'specified value' do
        driver = create_driver('parser_buffer_limit' => 500)
        assert_equal(500, driver.instance.parser_buffer_limit)
      end
    end
  end
end

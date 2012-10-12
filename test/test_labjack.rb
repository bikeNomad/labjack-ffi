require 'rubygems'
gem 'minitest'
require "minitest/autorun"
require "labjack"

LIB="lib"
SRC="src"

class Test::LabjackRuby < MiniTest::Unit::TestCase
  include LJ_FFI

  def setup
    LJDevice::debug=false
    assert(ljusb_get_dev_count(U3_PRODUCT_ID) > 0, "no U3 devices detected!")
    @lj = LJDevice.new(1, U3_PRODUCT_ID)
  end

  def teardown
    @lj.release
    @lj = nil
  end

  def test_config
    puts "===test_config"
    cu3 = @lj.configU3
    assert(cu3[:fioAnalog] == 15, "fioAnalog incorrect")
  end

  def test_configIO
    puts "===test_configIO"
    cio = @lj.configIO
    assert(cio[:fioAnalog] == 15, "fioAnalog incorrect")
  end

  def test_analogInput
    puts "===test_analogInput"
    cio = @lj.configIO(:fioAnalog => 15)
    ain = @lj.analogInput(AIN_POS_V_REG, AIN_NEG_SINGLE_ENDED)
    assert_in_epsilon()
  end
end

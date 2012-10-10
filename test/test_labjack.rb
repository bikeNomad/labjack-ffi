require 'rubygems'
gem 'minitest'
require "minitest/autorun"
require "labjack"

LIB="lib"
SRC="src"

class Test::LabjackRuby < MiniTest::Unit::TestCase
  include LJ_FFI

  def setup
    # LJDevice::debug=true
    assert(ljusb_get_dev_count(U3_PRODUCT_ID) > 0, "no U3 devices detected!")
    @lj = LJDevice.new(1, U3_PRODUCT_ID)
  end

  def teardown
    @lj.release
    @lj = nil
  end

  def test_config
    cu3 = @lj.configU3
    assert(cu3[:fioAnalog] == 15, "fioAnalog incorrect")
  end

  def test_configIO
    cio = @lj.configIO
    assert(cio[:fioAnalog] == 15, "fioAnalog incorrect")
  end
end

require 'labjack_ffi'
require 'labjack_structs'

class LJDevice
  include LJ_FFI

  def configU3
    cmd = ConfigU3Command.new(@command)
    cmd.writeMask = 0
    resp = cmd.do_command(@handle, @response)
  end

  def streamStart
    @streaming = true
  end

  def streamStop
    @streaming = false
  end

  class << self
    include LJ_FFI
    def testLib
      puts "Library version: #{'%.2f' % ljusb_get_library_version}"
      puts "U3 count: #{ljusb_get_dev_count U3_PRODUCT_ID}, " + 
        "U6 count: #{ljusb_get_dev_count U6_PRODUCT_ID}, " +
        "U12 count: #{ljusb_get_dev_count U12_PRODUCT_ID}, " +
        "UE9 count: #{ljusb_get_dev_count UE9_PRODUCT_ID}"
    end
  end

  def initialize(devnum, prod_id)
    @handle = ljusb_open_device(devnum, 0, prod_id)
    @command = FFI::MemoryPointer.new(256)
    @response = FFI::MemoryPointer.new(256)
    @streaming = false
  end

end

# ConfigU3          ext 26  38
# ConfigIO          ext 12  12
# ConfigTimerClock  ext 10  10
# Feedback          ext 64  64
# ReadMem           ext  8  40
# WriteMem          ext 40   8
# EraseMem          ext  8   8
# Reset            norm  4   4
# StreamConfig      ext 62   8
# StreamStart      norm  2   4
# StreamData                64
# StreamStop       norm  2   4
# Watchdog          ext 16  16
# SPI               ext 64  58
# AsynchConfig
# AsynchTX
# AsynchRX
# I2C
# SHT1X
# SetDefaults
# ReadDefaults

# test if run from command line
if __FILE__ == $0
  LJDevice.testLib
  lj = LJDevice.new(1, LJ_FFI::U3_PRODUCT_ID)
  puts "\nconfigU3:"
  puts lj.configU3
end

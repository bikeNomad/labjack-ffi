require 'labjack_ffi'
require 'commands'
require 'lj_device'

# test if run from command line
if __FILE__ == $0
  include LJ_FFI
  LJDevice::debug=true
  LJDevice.testLib
  if ljusb_get_dev_count(U3_PRODUCT_ID) > 0
    lj = LJDevice.new(1, U3_PRODUCT_ID)
    puts "\nconfigU3:"
    p lj.configU3
    puts "\nconfigIO:"
    p lj.configIO
  end
end

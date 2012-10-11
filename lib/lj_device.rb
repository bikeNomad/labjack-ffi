require 'labjack_ffi'
require 'command_base'
require 'commands'

class LJDevice
  include LJ_FFI

  def analogInput(posChan = AIN_POS_V_REG, negChan = AIN_NEG_SINGLE_ENDED, opts={})
    cmd = AnalogInputCommand.new(@command, opts)
    cmd.long_settling = opts[:long_settling]
    cmd.quick_sample = opts[:quick_sample]
    cmd.pos_channel = posChan
    cmd.neg_channel = negChan
    resp = cmd.do_command(@handle, @response, 0, false)
    resp
  end

  def configU3(opts={})
    cmd = ConfigU3Command.new(@command, opts)
    resp = cmd.do_command(@handle, @response, 0, false)
    resp[:firmwareVersion] = resp[:firmwareVersion].divmod(256)
    resp[:hardwareVersion] = resp[:hardwareVersion].divmod(256)
    resp
  end

  def configIO(opts={})
    cmd = ConfigIOCommand.new(@command, opts)
    resp = cmd.do_command(@handle, @response, 0, false)
    resp
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

    def devices
      @devices ||= []
    end

    def add_device(dev)
      devices << dev
      $stderr.puts("adding #{dev}") if debug?
    end

    def remove_device(dev)
      devices.delete(dev)
    end

    def close_all
      devices.each do |d|
        $stderr.puts("closing #{d}") if debug?
        d.release
      end
      @devices = []
    end

    def debug?
      @debug ||= false
    end

    def debug=(f)
      @debug = f
    end
  end

  def initialize(devnum, prod_id)
    @handle = ljusb_open_device(devnum, 0, prod_id)
    raise "open failed" unless @handle
    self.class.add_device(self)
    @command = FFI::MemoryPointer.new(256)
    @response = FFI::MemoryPointer.new(256)
    @streaming = false
  end

  def release
    if @handle
      ljusb_close_device(@handle)
      @handle = nil
    end
    @command = @response = nil
  end

  def debug?
    self.class.debug?
  end
end


END { LJDevice::close_all }

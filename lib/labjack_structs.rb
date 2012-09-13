require 'labjack_ffi'

module LJ_FFI
  extend NiceFFI::Library
  load_library 'labjackusb'

  class NormalCommand < NiceFFI::Struct
    def dumpCommand
      a = []
      (self.members - [:dataWords]).each { |m| a << ('%s: %02x' % [m, self[m]]) }
      aa = [ "dataWords: [" ]
      self[:dataWords].each { |d| aa << ('%02x' % d) }
      aa << "]"
      a << aa.join(' ')
      a.join(', ')
    end

    def initialize
      super
      order(:little)
    end
  end

  class ExtendedCommand < NiceFFI::Struct
    def dumpCommand
      a = []
      (self.members - [:dataWords]).each { |m| a << ('%s: %02x' % [m, self[m]]) }
      aa = [ "dataWords: [" ]
      self[:numberOfDataWords].times { |i| aa << ('%02x' % self[:dataWords][i]) }
      aa << "]"
      a << aa.join(' ')
      a.join(', ')
    end

    def initialize(*args)
      super(*args)
      order(:little)
    end
  end

  class ConfigU3Args < NiceFFI::Struct
    pack(1)
    layout(
      :writeMask, :uint16,
      :localID, :uint8,
      :timerCounterConfig, :uint8,
      :fioAnalog, :uint8,
      :fioDirection, :uint8,
      :fioStat, :uint8,
      :eioAnalog, :uint8,
      :eioDirection, :uint8,
      :eioStat, :uint8,
      :cioDirection, :uint8,
      :cioState, :uint8,
      :dac1Enable, :uint8,
      :dac0, :uint8,
      :dac1, :uint8,
      :timerClockConfig, :uint8,
      :timerClockDivisor, :uint8,
      :compatibilityOptions, :uint8,
      :reserved, :uint16
    )

    def initialize(*args)
      super(*args)
      order(:little)
    end
  end

  class ConfigU3Response < NiceFFI::Struct
    pack(1)
    layout(
      :origCmd, [:uint8, 6],  # bytes 0-5
      :errorcode, :uint8,
      :reserved, [ :uint8, 2],
      :firmwareVersion, :uint16,
      :bootloaderVersion, :uint16,
      :hardwareVersion, :uint16,
      :serialNumber, :uint32,
      :productID, :uint16,
      :localID, :uint8,
      :timerCounterMask, :uint8,
      :fioAnalog, :uint8,
      :fioDirection, :uint8,
      :fioState, :uint8,
      :eioAnalog, :uint8,
      :eioDirection, :uint8,
      :eioState, :uint8,
      :cioDirection, :uint8,
      :cioState, :uint8,
      :dac1Enable, :uint8,
      :dac0, :uint8,
      :dac1, :uint8,
      :timerClockConfig, :uint8,
      :timerClockDivisor, :uint8,
      :compatibilityOptions, :uint8,
      :versionInfo, :uint8
    )
  end
end

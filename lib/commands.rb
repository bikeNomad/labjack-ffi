require 'labjack_ffi'
require 'command_base'

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


module LJ_FFI
  class ConfigU3Response < NiceFFI::Struct
    pack(1)
    layout(
      :header, ExtendedCommandHeader,  # bytes 0-5
      :errorcode, :uint8,
      :reserved, :uint16,
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

  class ConfigU3Command < ExtendedCommand
    def command_code; 8; end
    def response_class; ConfigU3Response; end
    pack(1)
    layout(
      :header, ExtendedCommandHeader,
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
  end

  class ConfigIOResponse < NiceFFI::Struct
    pack(1)
    layout(
      :header, ExtendedCommandHeader,
      :errorcode, :uint8,
      :reserved, :uint8,
      :timerCounterConfig, :uint8,
      :dac1Enable, :uint8,
      :fioAnalog, :uint8,
      :eioAnalog, :uint8
    )
  end

  class ConfigIOCommand < ExtendedCommand
    def command_code; 11; end
    def response_class; ConfigIOResponse; end
    layout(
      :header, ExtendedCommandHeader,
      :writeMask, :uint16,
      :reserved, :uint8,
      :timerCounterConfig, :uint8,
      :dac1Enable, :uint8,    # ignored on HW 1.30+
      :fioAnalog, :uint8,
      :eioAnalog, :uint8
    )
  end

end

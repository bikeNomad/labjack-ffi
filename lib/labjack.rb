require 'labjack_ffi'
require 'labjack_structs'

class NiceFFI::Struct
  def dumpMembers
    a = []
    self.members.each do |m|
      begin
        a << ('%s: %02x' % [m, self[m]])
      rescue
        a << ('%s: %s' % [ m, self[m].to_s.inspect ])
      end
    end
    a.join(', ')
  end
end

class LJDevice
  include LJ_FFI

  # cmdNumber 0..14
  # dataWords 0 to 7 data words
  #
  # byte
  # 0 Checksum8: Includes bytes 1-15.
  # 1 Command Byte: DCCCWWW
  #   Bit 7: Destination bit: 0 = Local, 1 = Remote.
  #   Bits 6-3: Normal command number (0-14).
  #   Bits 2-0: Number of data words.
  # 2-15 Data Words.
  def formatNormalCommand(cmdNumber, dataWords, isLocal=true)
    cmd = normalCommand
    nWords = dataWords.size
    raise "too many data words" if nWords > cmd[:dataWords].size
    cmd.clear
    cmd[:commandByte] = (isLocal ? 0 : 0x80) | (cmdNumber << 3) | nWords
    # TODO use memcpy
    # cmd[:dataWords] = dataWords
    nWords.times { |i| cmd[:dataWords][i] = dataWords[i] }
    cmd[:checksum8] = checksum8(cmd[:dataWords], 1, -1)
    [ cmd, 2 + nWords * 2 ]
  end

  # Byte
  # 0 Checksum8: Includes bytes 1-5.
  # 1 Command Byte: D111_1WWW
  #   Bit 7: Destination bit: 0 = Local, 1 = Remote.
  #   Bits 6-3: 1111 specifies that this is an extended Command.
  #   Bits 2-0: Used with some commands.
  # 2 Number of data words
  # 3 Extended command number.
  # 4 Checksum16 (LSB)
  # 5 Checksum16 (MSB)
  # 6-255 Data words.
  def formatExtendedCommand(cmdNumber, dataWords, extraBits=0, isLocal=true)
    cmd = extendedCommand
    nWords = dataWords.size
    raise "too many data words" if nWords > cmd[:dataWords].size
    cmd.clear
    cmd[:commandByte] = (isLocal ? 0 : 0x80) | (0x0F << 3) | (extraBits & 0x07)
    cmd[:numberOfDataWords] = nWords
    cmd[:commandNumber] = cmdNumber
    cmd[:checksum16LSB] = 0
    cmd[:checksum16MSB] = 0
    # TODO use memcpy
    # cmd[:dataWords] = dataWords
    nWords.times { |i| cmd[:dataWords][i] = dataWords[i] }
    c16 = checksum16(cmd.to_ptr, 6, nWords * 2)
    cmd[:checksum16LSB] = c16[0]
    cmd[:checksum16MSB] = c16[1]
    cmd[:checksum8] = checksum8(cmd.to_ptr, 1, 5)
    [ cmd, 6 + nWords * 2 ]
  end

  # 15 bytes max; sum is 15*255=3825 max
  def checksum8(data, from, size)
    b = data.get_array_of_uint8(from, size)
    a = b.inject(0) { |acc,v| acc + v }.divmod(256)
    a[0] + a[1]
  end

  # 250 bytes max; sum is 250*255=63750 max
  # returns [lsb, msb]
  def checksum16(data, from, size)
    b = data.get_array_of_uint8(from,size)
    a = b.inject(0) { |acc,v| acc + v }.divmod(256)
    a.reverse
  end

  def extendedCommand
    ExtendedCommand.new(@command)
  end

  def normalCommand
    NormalCommand.new(@command)
  end

  def dumpBuffer(p, start, size)
    data = p.get_bytes(start, size)
    a = []
    size.times { |i| a << ('%02x' % data[i].ord) }
    a.join(' ')
  end

  def doExtendedCommand(cmdNumber, dataWords, responseLength, extraBits=0, isLocal=false)
    data, size = formatExtendedCommand(cmdNumber, dataWords, extraBits, isLocal)
puts data.dumpCommand
    sent = ljusb_write(@handle, data, size)
    raise "write failed" if sent != size
puts "send: #{dumpBuffer(data.to_ptr, 0, size)}"
    received = ljusb_read(@handle, @response, responseLength)
puts "recv: #{dumpBuffer(@response, 0, received)}"
    case received
    when 0
      raise "read failed"
    when 2
      raise "bad checksum" if @response.read_string == "\xB8\xB8"
    else
      raise "unexpected response: #{data.read_string.inspect}" unless received == responseLength
    end
    @response.slice(0, responseLength)
  end

  def configU3
    cmd = ConfigU3Args.new(FFI::MemoryPointer.new(ConfigU3Args.size))
    cmd[:writeMask] = 0
    resp = doExtendedCommand(0x08, cmd.to_ptr.get_array_of_uint16(0,10), ConfigU3Response.size)
    resp = ConfigU3Response.new(resp)
    resp.dumpMembers
  end

  def configIO
    resp = doExtendedCommand(0x0B, [ 0, 0, 0 ], 12)
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
  puts "\nconfigIO:"
  puts lj.configIO.read_string.inspect
  puts "\nconfigU3:"
  puts lj.configU3
end

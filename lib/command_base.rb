require 'labjack_ffi'

# fix for over-flattening in nice-ffi
class NiceFFI::Struct
  def to_hash
    return {} if members.empty?
    Hash[ *(members.collect{ |m| [m, self[m]] }.flatten!(1)) ]
  end
end

class String
  def hexdump
    self.unpack("H*")[0].gsub(/../, "\\0 ")
  end
end

module LJ_FFI
  extend NiceFFI::Library
  load_library('labjackusb')

  class CommandHeader < NiceFFI::Struct
    pack(1)

    def initialize(*args)
      super(*args)
      order(:little)
    end
  end

  class Command < NiceFFI::Struct
    include LJ_FFI

    pack(1)

    def transmit_size
      self.size + (self.size.odd? ? 1 : 0)
    end

    def num_data_words
      (self.transmit_size - header.size) >> 1
    end

    # subclass responsibility
    def command_code
      raise "no command code defined for #{self.class}"
    end

    # subclass responsibility
    def response_class
      raise "no response class defined for #{self.class}"
    end

    def receive_size
      response_class.size + (response_class.size.odd? ? 1 : 0)
    end

    def initialize(*args)
      super
      order(:little)
    end

  end

  class NormalCommandHeader < CommandHeader
    layout(:checksum8, :uint8, :commandByte, :uint8)
  end

  # cmdNumber 0..14
  # dataWords 0 to 7 data words
  #
  # byte
  # 0 Checksum8: Includes bytes 1-15.
  # 1 Command Byte: DCCCCWWW
  #   Bit 7: Destination bit: 0 = Local, 1 = Remote.
  #   Bits 6-3: Normal command number (0-14).
  #   Bits 2-0: Number of data words.
  # 2-15 Data Words.
  # subclasses should have a NormalCommandHeader member called :header at offset 0.
  class NormalCommand < Command
    # 15 bytes max; sum is 15*255=3825 max
    # return value here is 256 maximum
    def cs8
      s = self.to_bytes.slice(1, self.size-1).sum
      a = s.divmod(256)
      a[0] + a[1]
    end

    # assumes all other fields are set up already
    def format(cmdNumber, isLocal=true)
      header.commandByte = (isLocal ? 0 : 0x80) | (cmdNumber << 3) | self.num_data_words
      header.checksum8 = self.cs8
    end
  end

  class ExtendedCommandHeader < CommandHeader
    layout(
           :checksum8, :uint8,
           :commandByte, :uint8,
           :numberOfDataWords, :uint8,
           :commandNumber, :uint8,
           :checksum16LSB, :uint8,
           :checksum16MSB, :uint8
    )
  end

  # subclasses should have an ExtendedCommandHeader member called :header at offset 0.
  # Byte
  # 0 Checksum8: Includes bytes 1-5.
  # 1 Command Byte: D111_1WWW
  #   Bit 7: Destination bit: 0 = Local, 1 = Remote. (ignored on U3)
  #   Bits 6-3: 1111 specifies that this is an extended Command.
  #   Bits 2-0: Used with some commands.
  # 2 Number of data words
  # 3 Extended command number.
  # 4 Checksum16 (LSB)
  # 5 Checksum16 (MSB)
  # 6-255 Data words.
  class ExtendedCommand < Command

    # checksum8 of bytes 1-5 (header)
    def cs8 
      s = self.to_bytes.slice(1, 5).sum
      a = s.divmod(256)
      a[0] + a[1]
    end

    # 250 bytes max; sum is 250*255=63750 max
    # returns [lsb, msb]
    def cs16
      s = self.to_bytes.slice(6, self.size-6).sum
      a = s.divmod(256)
      a.reverse
    end

    # assumes all other fields are set up already
    def format(extraBits=0, isLocal=true)
      header.commandByte = (isLocal ? 0 : 0x80) | 0x78 | (extraBits & 0x07)
      header.numberOfDataWords = self.num_data_words
      header.commandNumber = self.command_code
      header.checksum16LSB = 0
      header.checksum16MSB = 0
      c16 = self.cs16
      header.checksum16LSB = c16[0]
      header.checksum16MSB = c16[1]
      header.checksum8 = self.cs8
    end

    def do_command(handle, respbuf, extraBits=0, isLocal=true)
      self.format(extraBits, isLocal)
      if LJDevice::debug?
        $stderr.puts "Sent(#{self.transmit_size}) #{self.to_bytes.slice(0, self.transmit_size).hexdump}"
        $stderr.puts self.to_hash.inspect
      end
      # send command
      sent = LJ_FFI::ljusb_write(handle, self.to_ptr, self.transmit_size)
      raise "write failed" if sent != self.size
      # get response
      response = response_class.new(respbuf)
      received = LJ_FFI::ljusb_read(handle, response.to_ptr, self.receive_size)
      case received
      when response.size
        resp = response.to_hash
        if LJDevice::debug?
          $stderr.puts "Received(#{self.receive_size}): #{response.to_bytes.slice(0, self.receive_size).hexdump}"
          $stderr.puts resp.inspect
        end
        resp.delete(:header)
        resp
      when 0
        raise "read failed"
      when 2
        raise "bad checksum" if response.to_bytes == "\xB8\xB8"
      else
        raise "error: #{received}"
      end
    end
  end

end

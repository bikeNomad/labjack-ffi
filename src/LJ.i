%module LJ_FFI

%{
require 'rubygems'
require 'ffi'
require 'nice-ffi'

module LibC
  extend NiceFFI::Library
  load_library('libc')
  attach_function :memcpy, [ :pointer, :pointer, :size_t ], :pointer
end

module LJ_FFI
  extend NiceFFI::Library
  load_library('labjackusb')

  class NormalCommand < NiceFFI::Struct
    pack 1
  end

  class ExtendedCommand < NiceFFI::Struct
    pack 1
  end

%}

%rename("%(utitle)s", %$isfunction) "";   // LJUSB_GetLibraryVersion => ljusb_get_library_version

struct NormalCommand {
  uint8_t checksum8;
  uint8_t commandByte;
  uint16_t dataWords[7];
};

struct NormalCommandDataBytes {
  uint8_t dataBytes[14];
};

struct ExtendedCommand {
  uint8_t checksum8;
  uint8_t commandByte;
  uint8_t numberOfDataWords;
  uint8_t commandNumber;
  uint8_t checksum16LSB;
  uint8_t checksum16MSB;
  uint16_t dataWords[125];
};

struct ExtendedCommandDataBytes {
  uint8_t dataBytes[250];
};

%include <labjackusb.h>

%{
end
%}

// vim: ft=swig ts=2 sw=2 et

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

%}

%rename("%(utitle)s", %$isfunction) "";   // LJUSB_GetLibraryVersion => ljusb_get_library_version

%include <labjackusb.h>

%{
end
%}

// vim: ft=swig ts=2 sw=2 et

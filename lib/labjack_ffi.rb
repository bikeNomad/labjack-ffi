
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

  LJUSB_LINUX_LIBRARY_VERSION = 2.0
  UE9_PRODUCT_ID = 9
  U3_PRODUCT_ID = 3
  U6_PRODUCT_ID = 6
  U12_PRODUCT_ID = 1
  BRIDGE_PRODUCT_ID = 0x0501
  UNUSED_PRODUCT_ID = -1
  UE9_PIPE_EP1_OUT = 1
  UE9_PIPE_EP1_IN = 0x81
  UE9_PIPE_EP2_IN = 0x82
  U3_PIPE_EP1_OUT = 1
  U3_PIPE_EP2_IN = 0x82
  U3_PIPE_EP3_IN = 0x83
  U6_PIPE_EP1_OUT = 1
  U6_PIPE_EP2_IN = 0x82
  U6_PIPE_EP3_IN = 0x83
  U12_PIPE_EP1_IN = 0x81
  U12_PIPE_EP2_OUT = 2
  BRIDGE_PIPE_EP1_IN = 0x81
  BRIDGE_PIPE_EP1_OUT = 1
  attach_function :ljusb_get_library_version, :LJUSB_GetLibraryVersion, [  ], :float
  attach_function :ljusb_get_dev_count, :LJUSB_GetDevCount, [ :ulong ], :ulong
  attach_function :ljusb_get_dev_counts, :LJUSB_GetDevCounts, [ :pointer, :pointer, :uint ], :int
  attach_function :ljusb_open_all_devices, :LJUSB_OpenAllDevices, [ :pointer, :pointer, :uint ], :int
  attach_function :ljusb_open_device, :LJUSB_OpenDevice, [ :uint, :uint, :ulong ], :pointer
  attach_function :ljusb_write, :LJUSB_Write, [ :pointer, :pointer, :ulong ], :ulong
  attach_function :ljusb_read, :LJUSB_Read, [ :pointer, :pointer, :ulong ], :ulong
  attach_function :ljusb_stream, :LJUSB_Stream, [ :pointer, :pointer, :ulong ], :ulong
  attach_function :ljusb_close_device, :LJUSB_CloseDevice, [ :pointer ], :void
  attach_function :ljusb_is_handle_valid, :LJUSB_IsHandleValid, [ :pointer ], :bool
  attach_function :ljusb_abort_pipe, :LJUSB_AbortPipe, [ :pointer, :ulong ], :bool
  attach_function :ljusb_bulk_read, :LJUSB_BulkRead, [ :pointer, :uchar, :pointer, :ulong ], :ulong
  attach_function :ljusb_bulk_write, :LJUSB_BulkWrite, [ :pointer, :uchar, :pointer, :ulong ], :ulong

end

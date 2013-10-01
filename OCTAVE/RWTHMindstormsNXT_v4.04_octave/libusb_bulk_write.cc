#include <octave/oct.h>
#include <usb.h>

DEFUN_DLD (libusb_bulk_write, args, nargout, "libusb bulk_write wrapper")
{
  usb_dev_handle *dev;
  int ep, size, timeout, ret, i;
  char bytes[255];

  NDArray a1 = args(0).array_value();
  NDArray a2 = args(1).array_value();
  NDArray a3 = args(2).array_value();
  NDArray a4 = args(3).array_value();
  NDArray a5 = args(4).array_value();
  unsigned long al1 = (unsigned long)a1(0);
  dev = (usb_dev_handle *) al1;
  ep = (int)a2(0);
  size = (int)a4(0);
  timeout = (int)a5(0);
  for (i=0; i<size; i++) bytes[i] = a3(i);

  ret = usb_bulk_write(dev, ep, bytes, size, timeout);
  return octave_value(ret);
}

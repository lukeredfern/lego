#include <octave/oct.h>
#include <usb.h>

DEFUN_DLD (libusb_reset, args, nargout, "libusb reset wrapper")
{
  usb_dev_handle *dev;
  int ret;

  NDArray a1 = args(0).array_value();
  unsigned long al1 = (unsigned long)a1(0);
  dev = (usb_dev_handle *) al1;

  ret = usb_reset(dev);
  return octave_value(ret);
}

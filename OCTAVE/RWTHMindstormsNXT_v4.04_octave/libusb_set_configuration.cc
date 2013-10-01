#include <octave/oct.h>
#include <usb.h>

DEFUN_DLD (libusb_set_configuration, args, nargout, "libusb set_configuration wrapper")
{
  usb_dev_handle *dev;
  int ret, configuration;

  NDArray a1 = args(0).array_value();
  NDArray a2 = args(1).array_value();
  unsigned long al1 = (unsigned long)a1(0);
  dev = (usb_dev_handle *) al1;
  configuration = (unsigned long)a2(0);

  ret = usb_set_configuration(dev, configuration);
  return octave_value(ret);
}

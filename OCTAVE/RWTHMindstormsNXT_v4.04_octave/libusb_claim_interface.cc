#include <octave/oct.h>
#include <usb.h>

DEFUN_DLD (libusb_claim_interface, args, nargout, "libusb claim_interface wrapper")
{
  usb_dev_handle *dev;
  int ret, interface;

  NDArray a1 = args(0).array_value();
  NDArray a2 = args(1).array_value();
  unsigned long al1 = (unsigned long)a1(0);
  dev = (usb_dev_handle *) al1;
  interface = (unsigned long)a2(0);

  ret = usb_claim_interface(dev, interface);
  return octave_value(ret);
}

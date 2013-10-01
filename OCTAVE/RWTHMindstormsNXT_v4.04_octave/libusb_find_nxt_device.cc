#include <octave/oct.h>
#include <usb.h>

using namespace std;

#define ID_VENDOR_LEGO 1684
#define ID_PRODUCT_NXT 2

DEFUN_DLD (libusb_find_nxt_device, args, nargout, "Finds a Lego NXT device connected via USB")
{
  struct usb_bus *busses, *bus;
  struct usb_device *dev;
  struct usb_dev_handle *DevHandle;
  bool foundNXT = false;
  char buf[255];
  int bytesRead;
  unsigned long ret;
  octave_value_list retlist;

  usb_init();
  usb_find_busses();
  usb_find_devices();
  busses = usb_get_busses();
  
  for (bus = busses; bus; bus = bus->next) {

    for (dev = bus->devices; dev; dev = dev->next) {

      if ((dev->descriptor.idVendor == ID_VENDOR_LEGO) && (dev->descriptor.idProduct == ID_PRODUCT_NXT)) {

	DevHandle = usb_open(dev);
	bytesRead = usb_get_string_simple(DevHandle, dev->descriptor.iSerialNumber, buf, sizeof(buf));
	if (args.length() == 0) foundNXT = true;
	else {
	  charMatrix ch = args(0).char_matrix_value();
	  string tmp = ch.row_as_string(0);
	  if (!strcmp(tmp.c_str(), buf)) foundNXT = true;
	}

	if (!foundNXT) usb_close(DevHandle);
	else break;
      }

    } // loop over devices

    if (foundNXT) break;

  } // loop over busses

  if (!foundNXT) ret = 0;
  else ret = (unsigned long)DevHandle;

  retlist(0) = ret;
  retlist(1) = buf;

  return octave_value_list(retlist);
}


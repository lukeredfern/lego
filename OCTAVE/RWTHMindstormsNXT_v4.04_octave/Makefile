# Makefile for libusb wrappers

all: libusb_bulk_read.oct libusb_bulk_write.oct libusb_claim_interface.oct libusb_close.oct libusb_find_nxt_device.oct libusb_release_interface.oct libusb_reset.oct libusb_set_configuration.oct

clean:
	/bin/rm -f *.oct *.o

distclean: clean
	/bin/rm -f *~ octave-core core

%.oct: %.cc
	mkoctfile $< -lusb

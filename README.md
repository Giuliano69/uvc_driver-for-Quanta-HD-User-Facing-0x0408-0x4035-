# Here is a README file for people who will need it to install the driver correctly, this guide is made for Fedora users but other Linux users can also adopt it as per their distros. Make sure to change the code for the driver as per your lsusb output.

1. Open **terminal** and do: `cd $HOME`
2. Then run this command: `dnf download --source kernel-modules-extra-$(uname -r)`
3. Then run unzip command to extract the source: `unzip kernel-6.4.12-200.fc38.src.zip -d kernel; cd kernel;`
4. Then extract the **linux-*.tar.xz**: `tar -xvf linux-*.tar.xz;`
5. Then change directory _replace x here_ : `cd linux-x.x.xx/drivers/media/usb/uvc`
6. Then Type : `gnome-text-editor uvc_driver.c`
7. Now search for this line with `ctrl+f` **static const struct usb_device_id uvc_ids[] = {**
8. Add the following on the next line:
```
/* Quanta ACER HD User Facing 4033 - Experimental !! */  
  { .match_flags 	= USB_DEVICE_ID_MATCH_DEVICE  
                        | USB_DEVICE_ID_MATCH_INT_INFO,  
    .idVendor = 0x0408,  
    .idProduct = 0x4033,  
    .bInterfaceClass = USB_CLASS_VIDEO,  
    .bInterfaceSubClass = 1,  
    .bInterfaceProtocol =	UVC_PC_PROTOCOL_15,  
    .driver_info = (kernel_ulong_t) &(const struct uvc_device_info ) {  
                                                                       .uvc_version = 0x010a, } },
```
9. Save this file.
10. Run: `sudo make -j4 -C /lib/modules/$(uname -r)/build M=$(pwd) modules`
11.  Now run: `sudo rmmod uvcvideo.ko`
12. Then run: `sudo insmod ./uvcvideo.ko`

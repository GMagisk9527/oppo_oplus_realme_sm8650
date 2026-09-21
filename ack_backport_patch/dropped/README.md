# Dropped from default ack_backport (boot regression vs acbd3d2)

c4cc084 (all 8 ACK patches) cannot boot; acbd3d2 can.
These three are the ones that touch USB enumeration / first suspend.

- 002 xhci ep0 maxpacket on reset: xhci_endpoint_reset() calls
  xhci_check_ep0_maxpacket(xhci, xhci->devs[udev->slot_id]) without a
  vdev NULL check. Vendor originally required host_ep->hcpriv and vdev.
- 003 xhci urb enqueue lock: moves xhci_vendor_usb_offload_skip_urb()
  and urb->ep dereference before if (!urb) / xhci_check_args().
  002+003 rewrite the same xhci.c paths; drop together.
- 008 PM: pm_wq loses WQ_FREEZABLE and gains WQ_UNBOUND;
  __device_suspend_late() uses pm_runtime_disable() which waits for
  in-flight RPM. Vendor used __pm_runtime_disable(dev, false).

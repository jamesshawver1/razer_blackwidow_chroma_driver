KERNELDIR:=/lib/modules/$(shell uname -r)/build
DRIVERDIR:=$(shell pwd)/driver
MODULEDIR=/lib/modules/$(shell uname -r)/kernel/drivers/usb/misc

all: librazer_chroma razer_daemon razer_daemon_controller razer_examples razer_kbd

razer_kbd:
	@echo "::\033[32m COMPILING razer chroma kernel module\033[0m"
	@echo "========================================"
	make -C $(KERNELDIR) SUBDIRS=$(DRIVERDIR) modules > /dev/null 2>&1
	#added redirect to remove output of a useless makefile warning

razer_kbd_verbose:
	@echo "::\033[32m COMPILING razer chroma kernel module\033[0m"
	@echo "========================================"
	make -C $(KERNELDIR) SUBDIRS=$(DRIVERDIR) modules


librazer_chroma: 
	make -C lib all
	cp lib/librazer_chroma.a lib/librazer_chroma.da lib/librazer_chroma.so lib/librazer_chroma_debug.so daemon
	cp lib/librazer_chroma.a lib/librazer_chroma.da lib/librazer_chroma.so lib/librazer_chroma_debug.so daemon_controller

librazer_chroma_clean: 
	make -C lib clean 

razer_daemon: 
	make -C daemon all

razer_daemon_clean: 
	make -C daemon clean 

razer_daemon_controller: 
	make -C daemon_controller all

razer_daemon_controller_clean: 
	make -C daemon_controller clean 

razer_examples: 
	make -C examples all

razer_examples_clean: 
	make -C examples clean 

install: all
	make -C lib install
	make -C daemon install
	make -C daemon_controller install
	@echo "::\033[32m INSTALLING razer chroma kernel module\033[0m"
	@echo "====================================================="
	cp $(DRIVERDIR)/razerkbd.ko $(MODULEDIR)
	chown root:root $(MODULEDIR)/razerkbd.ko
	depmod
	@echo "::\033[32m INSTALLING razer chroma udev rules\033[0m"
	@echo "====================================================="
	cp install_files/udev/95-razerkbd.rules /etc/udev/rules.d
	chown root:root /etc/udev/rules.d/95-razerkbd.rules
	@echo "::\033[32m INSTALLING razer chroma dbus policy\033[0m"
	@echo "====================================================="
	cp install_files/dbus/org.voyagerproject.razer.daemon.conf /etc/dbus-1/system.d
	chown root:root /etc/dbus-1/system.d/org.voyagerproject.razer.daemon.conf
	@echo "::\033[32m INSTALLING razer daemon init.d file\033[0m"
	@echo "====================================================="
	cp install_files/init.d/razer_bcd /etc/init.d
	chown root:root /etc/init.d/razer_bcd
	cp install_files/init.d/activate_driver.sh /usr/sbin/razer_blackwidow_chroma_activate_driver.sh
	chown root:root /usr/sbin/razer_blackwidow_chroma_activate_driver.sh
	ln -fs ../init.d/razer_bcd /etc/rc2.d/S24razer_bcd
	ln -fs ../init.d/razer_bcd /etc/rc3.d/S24razer_bcd
	ln -fs ../init.d/razer_bcd /etc/rc4.d/S24razer_bcd
	ln -fs ../init.d/razer_bcd /etc/rc5.d/S24razer_bcd

	ln -fs ../init.d/razer_bcd /etc/rc0.d/K02razer_bcd
	ln -fs ../init.d/razer_bcd /etc/rc1.d/K02razer_bcd
	ln -fs ../init.d/razer_bcd /etc/rc6.d/K02razer_bcd

uninstall:
	make -C lib uninstall
	make -C daemon uninstall
	rm /etc/init.d/razer_bcd
	rm /etc/udev/rules.d/95-razerkbd.rules
	rm /etc/rc2.d/S24razer_bcd
	rm /etc/rc3.d/S24razer_bcd
	rm /etc/rc4.d/S24razer_bcd
	rm /etc/rc5.d/S24razer_bcd
	rm /etc/rc0.d/K02razer_bcd
	rm /etc/rc1.d/K02razer_bcd
	rm /etc/rc6.d/K02razer_bcd
	rm /etc/dbus-1/system.d/org.voyagerproject.razer.daemon.conf
	rm /usr/sbin/razer_blackwidow_chroma_activate_driver.sh


clean: librazer_chroma_clean razer_daemon_clean razer_daemon_controller_clean razer_examples_clean razer_kbd_clean
	rm -f daemon/librazer_chroma.a daemon/librazer_chroma.da daemon/librazer_chroma.so daemon/librazer_chroma_debug.so
	rm -f daemon_controller/librazer_chroma.a daemon_controller/librazer_chroma.da daemon_controller/librazer_chroma.so daemon_controller/librazer_chroma_debug.so

razer_kbd_clean:
	make -C $(KERNELDIR) SUBDIRS=$(DRIVERDIR) clean > /dev/null 2>&1
	#added redirect to remove output of a useless makefile warning


# common.mk needs to be copied from common.mk.template and filled with correct parameters
# for the asar executeable and the paths to the original ROM files

include common.mk


help:
	@echo "usage: make [option]"
	@echo ""
	@echo "Options:"
	@echo "     dist           Create distribution package"
	@echo "     patch          Patch original SMW"
	@echo "     compare        Compare patches to reference ROMs"
dist:
	@echo "Creating distribution package in build/"	

	@echo "Cleaning build dir"
	rm -rf build
	mkdir -p build

	@echo "Copying Documentation"
	cp README.md build/README.txt

	@echo "Copying Configuration and includes"
	mkdir -p build/config
	mkdir -p build/includes
	cp src/config/retry_config.asm build/config/retry_config.asm
	cp src/includes/hardware_registers.asm build/includes/hardware_registers.asm
	cp src/includes/rammap.asm build/includes/rammap.asm

	@echo "Copying sources"
	cp src/retry_system.asm build/retry_system.asm

	@echo "Creating archive"
	cd build; tar cvzf ../build.tgz *


patch:
	@echo "Patching SMW..."
	cd src; $(ASAR_BIN) retry_system.asm $(ORIGINAL_ROM) ../original-patched.smc
	@echo "Patching Reference SMC"
	cd src; $(ASAR_BIN) retry_system.asm $(REFERENCE_ROM) ../reference-patched.smc
	@echo "Patching Kaizo SMC"
	cd src; $(ASAR_BIN) retry_system.asm $(KAIZO_ROM) ../kaizo-patched.smc

compare:
	@echo "Comparing ROMs to originals"
	@-cmp original-patched.smc originals/original-patched.smc; if [ $$? -eq 0 ] ; then echo "ORIGINAL ROM MATCHES" ; fi;  true
	@-cmp reference-patched.smc originals/reference-patched.smc; if [ $$? -eq 0 ] ; then echo "REFERENCE ROM MATCHES" ; fi;  true
	@-cmp kaizo-patched.smc originals/kaizo-patched.smc; if [ $$? -eq 0 ] ; then echo "KAIZO ROM MATCHES" ; fi;  true
	@echo "Done comparing!"



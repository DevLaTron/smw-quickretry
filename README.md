Quick Retry System 1.0
======================

 This patch adds a quick retry option to Super Mario World for the SNES. It has been written for simplicity and best
effort has been made to provide a thorough documentation of the source.

 Using this patch you can give the player a choice to Retry or exit the level, default to exit or instant retry, either
globally or on a per level basis. Additionally, SELECT+START can be enabled to exit a level. You can optionally deactivate
the deduction of lives upon death, and define sound effects and message popup options.

The patch uses variable names equal or at least similar to those used in SMWDisX created by dotsarecool for reference.

Additionally, the patch has a hirarchical structure of includes and config directories to keep things sorted.

All source code is available on GITHUB under https://github.com/DevLaTron/smw-quickretry. Please report all bugs and/or
modifications to that repository. Pull requests are welcome!

This code is a rewrite/update/fork of Retry- System (+ Simple Multi Midway) by worldpeace.


Configuration and installation from a release version
=====================================================

1. Backup your ROM file to a safe place.
2. Edit the file config/retry_config.asm to fit your needs. See the comments for explanations.
3. Apply the patch to your ROM: asar retry.asm [your_rom.smc]


Configuration and building from GITHUB
======================================
1. Edit and configure common.mk to fit your needs.
2. Add SMW ROMS to an appropriate directory.
3. Run "make patch" to create patched ROMs for testing.
4. Run "make dist" to create a release package.


Changelog
=========

Version 1.0 2018-10-13
----------------------
- First public release on GITHUB.

Version 0.1 2018-09-20
----------------------
- Initial version, not for public use.


Quick Retry System 1.3
======================
 This patch adds a quick retry option to Super Mario World for the SNES. It has been written for simplicity and best
effort has been made to provide a thorough documentation of the source. 

 Using this patch you can give the player a choice to retry or exit the level, default to exit or instant retry, either
globally or on a per level basis. Additionally, SELECT+START can be enabled to exit a level. You can optionally deactivate
the deduction of lives upon death, and define sound effects and message popup options. Finally, you have a choice for
resetting the RNG upon death, trying to ensure the same RNG ocurring on every run.

The patch uses variable names equal or at least similar to those used in SMWDisX created by dotsarecool for reference.

Additionally, the patch has a hirarchical structure of includes and config directories to keep things sorted.

All source code is available on GITHUB under https://github.com/DevLaTron/smw-quickretry. Please report all bugs and/or
modifications to that repository. Pull requests are welcome!

This code is a rewrite/update/fork of Retry- System (+ Simple Multi Midway) by worldpeace.


Requirements:
=============
 To use this patch, a version of SMW is required. To apply the patch ASAR version >= 1.6 is required. ASAR can be found
here: https://github.com/RPGHacker/asar

 To participate in development, a version of Linux is recommended. Release packaging is done via Makefiles, and tested
under Linux only.


Configuration and installation from a release version
=====================================================
The most current version can be downloaded from here: 

https://github.com/DevLaTron/smw-quickretry/releases

You only need this download to patch your ROM.

1. Backup your ROM file to a safe place.
2. Edit the file config/quickretry_config.asm to fit your needs. See the comments for explanations.
3. Apply the patch to your ROM: asar quickretry.asm [your_rom.smc]


Configuration and building from GITHUB
======================================
Use this if you want to contribute or extend Quick Retry. Check out / clone a copy of the repository found here:

https://github.com/DevLaTron/smw-quickretry.git

1. Edit and configure common.mk to fit your needs.
2. Add SMW ROMS to an appropriate directory. This allows you to use make to patch and compare your code changes.
3. Run "make patch" to create patched ROMs for testing. You can then use the patched ROMs in an emulator for testing.
4. Run "make dist" to create a release package.


Changelog
=========

Version 1.3 2018-11-28
----------------------
- Added option to continue playing music when game is paused.
- Added option to continue playing music when retry prompt is active. Disables death SFX when retrying.
- Added option to disable prompt injection. This allows Message Box manipulation boxes to be compatible. Requires setting prompt type to $02 or $03 (disable).
- Moved config loading and Autoclean to front of file.
- Minor bug fixes and code rearrangement.

Version 1.2 2018-10-14
----------------------
- Renamed ASM files to better reflect package structure and naming.
- Update README.md to better reflect some details.
- Updates to Makefiles.
- Corrected versioning.
- Updates to code documentation.
- Added MD5 checksums for testing and comparison ROMs.

Version 1.1 2018-10-13
----------------------
- First public release on GITHUB.

Version 0.1 2018-09-20
----------------------
- Initial version, not for public use.

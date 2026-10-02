# Liquid Glass Launcher
A standalone Android launcher prototype with a translucent, frosted-glass inspired interface.

## Build
Open in Android Studio or use GitHub Actions. The debug APK is uploaded as a workflow artifact.

## Install
Install the debug APK, then choose **Liquid Glass Launcher** when Android asks for your default Home app.


## ZTE Launcher Liquid Glass patch

The `liquid-glass/` directory contains the editable glass UI resources and Termux scripts for applying the design to an apktool-decoded ZTE/MiFavor Launcher3 source tree. It targets translucent rounded panels, light/dark glass surfaces and the launcher's existing blur pipeline.

Apply with:

    bash liquid-glass/scripts/apply_glass_patch.sh ~/zte-launcher/launcher-src

Then inspect blur support with:

    bash liquid-glass/scripts/find_existing_blur.sh ~/zte-launcher/launcher-src

Keep the original system launcher as a recovery copy and test the rebuilt APK before replacing it.

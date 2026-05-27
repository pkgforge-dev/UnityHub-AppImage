#!/bin/sh

set -eu

if [ "${DEVEL_RELEASE-}" = 1 ]; then
	# Currently massively OOD, will fix later
	pkg=unityhub-beta
else
	pkg=unityhub
fi

ARCH=$(uname -m)
VERSION=$(pacman -Q "$pkg" | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/unityhub.png
export DESKTOP=/usr/share/applications/unityhub.desktop

# Deploy dependencies
quick-sharun ./AppDir/bin/*

# Additional changes can be done in between here

# This is hardcoded to look into /usr/bin/ldd and causes a crash
# looks like we only need to patch this path away, it seems to work without it
sed -i -e 's|/usr/bin/ldd|/XXX/YYY/ZZZ|g' ./AppDir/bin/resources/app.asar

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage

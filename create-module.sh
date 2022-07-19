#!/bin/bash

git clone https://github.com/Lyceris-chan/revanced-magisk-template

cp build/revanced-root-signed.apk revanced-magisk-template
cp com.google.android.youtube.apk revanced-magisk-template

cd revanced-magisk-template

zip -r ReVanced-v17.27.39-MagiskModule.zip ./*

cd ..

cp revanced-magisk-template/ReVanced-v17.27.39-MagiskModule.zip .

rm -rf revanced-magisk-template

git clone https://github.com/Lyceris-chan/revanced-magisk-template -b music

cp build/revanced-music-root-signed.apk revanced-magisk-template
cp com.google.android.apps.youtube.music.apk revanced-magisk-template

cd revanced-magisk-template

zip -r ReVancedMusic-v5.14.53-MagiskModule.zip ./*

cd ..

cp revanced-magisk-template/ReVancedMusic-v5.14.53-MagiskModule.zip .

rm -rf revanced-magisk-template

#!/bin/bash

# Latest compatible version of apks
# YouTube Music 5.16.51
# YouTube 17.29.34
# Vanced microG 0.2.24.220220
# Twitter 9.52.0-release.0
# Reddit 2022.28.0

# Artifacts associative array aka dictionary
declare -A artifacts

artifacts["revanced-cli.jar"]="revanced/revanced-cli revanced-cli .jar"
artifacts["revanced-integrations.apk"]="Lyceris-chan/revanced-integrations app-release-unsigned .apk"
artifacts["revanced-patches.jar"]="Lyceris-chan/revanced-patches revanced-patches .jar"
artifacts["apkeep"]="EFForg/apkeep apkeep-x86_64-unknown-linux-gnu"

get_artifact_download_url () {
    # Usage: get_download_url <repo_name> <artifact_name> <file_type>
    local api_url="https://api.github.com/repos/$1/releases/latest"
    local result=$(curl $api_url | jq ".assets[] | select(.name | contains(\"$2\") and contains(\"$3\") and (contains(\".sig\") | not)) | .browser_download_url")
    echo ${result:1:-1}
}

# Fetch all the dependencies
for artifact in "${!artifacts[@]}"; do
    if [ ! -f $artifact ]; then
        echo "Downloading $artifact"
        curl -L -o $artifact $(get_artifact_download_url ${artifacts[$artifact]})
    fi
done

# Fetch microG
chmod +x apkeep

if [ ! -f "vanced-microG.apk" ]; then
    echo "Downloading Vanced microG"
    ./apkeep -a com.mgoogle.android.gms@$VMG_VERSION .
    mv com.mgoogle.android.gms@$VMG_VERSION.apk vanced-microG.apk
fi

echo "************************************"
echo "Building YouTube APK"
echo "************************************"

mkdir -p build
# All patches will be included by default, you can exclude patches by appending -e patch-name to exclude said patch.
# Example: -e microg-support

# All available patches can be found here: https://github.com/revanced/revanced-patches#list-of-available-patches

if [ -f "com.google.android.youtube.apk" ]
then
    echo "Building Root APK"
    java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                               -i swipe-controls -i enable-wide-searchbar -i compact-header -i hdr-auto-brightness -i hdr-auto-brightness -i force-vp9-codec -i timeline-ads -i tasteBuilder-remover -i hide-get-premium -i upgrade-button-remover -i background-play -i music-video-ads -i codecs-unlock -i exclusive-audio-playback -i seekbar-tapping -i minimized-playback -i disable-create-button -i return-youtube-dislike -i premium-heading -i custom-branding -i disable-fullscreen-panels -i old-quality-layout -i hide-shorts-button -i hide-watermark -i sponsorblock -i custom-playback-speed -i video-ads -i general-ads -i hide-infocard-suggestions \
                               -e microg-support \
                               -a com.google.android.youtube.apk -o build/revanced-root.apk
    echo "Building Non-root APK"
    java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                               -i swipe-controls \
                               -e enable-wide-searchbar \
                               -a com.google.android.youtube.apk -o build/revanced-nonroot.apk
else
    echo "Cannot find YouTube APK, skipping build"
fi

echo ""
echo "************************************"
echo "Building YouTube Music APK"
echo "************************************"
if [ -f "com.google.android.apps.youtube.music.apk" ]
then
    echo "Building Root APK"
    java -jar revanced-cli.jar -b revanced-patches.jar \
                               -e music-microg-support \
                               -a com.google.android.apps.youtube.music.apk -o build/revanced-music-root.apk
    echo "Building Non-root APK"
    java -jar revanced-cli.jar -b revanced-patches.jar \
                               -a com.google.android.apps.youtube.music.apk -o build/revanced-music-nonroot.apk
else
   echo "Cannot find YouTube Music APK, skipping build"
fi

echo ""
echo "************************************"
echo "Building Twitter APK"
echo "************************************"
if [ -f "com.twitter.android.apk" ]
then
    java -jar revanced-cli.jar -b revanced-patches.jar \
                               -a com.twitter.android.apk -o build/twitter.apk
else
   echo "Cannot find Twitter APK, skipping build"
fi

echo ""
echo "************************************"
echo "Building Reddit APK"
echo "************************************"
if [ -f "com.reddit.frontpage.apk" ]
then
    java -jar revanced-cli.jar -b revanced-patches.jar -r \
                               -a com.reddit.frontpage.apk -o build/reddit.apk
else
   echo "Cannot find Reddit APK, skipping build"
fi

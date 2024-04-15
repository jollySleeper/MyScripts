#!/system/bin/sh

checkPrintAndExit () {
    if [ $? -ne 0 ]; then
        echo "$1 APK Failed :("
        echo "Try Again!!"
        exit 1
    fi
}

if [[ ! -d /storage/sdcard0/Apks ]]; then
    mkdir -p /storage/sdcard0/Apks
fi
cd /storage/sdcard0/Apks

if [[ -z $1 ]] && [[ -z $2 ]]; then
    echo "Please Provide Appname and URL"
    exit 1
fi

echo "Downloading APK"
/data/local/tmp/wget -c -t 20 "$2" --no-check-certificate -O "$1.apk" --progress=bar:force 2>&1 | tail -f -n +8
checkPrintAndExit "Downloading"

echo "Installing APK '$1.apk'"
pm install -r "$1.apk"
checkPrintAndExit "Installing"

echo "Done"

# Waydroid GNSS for Android 13

The release assets are Waydroid vendor overlays for x86_64 and ARM64. The AIDL v2 service reads `persist.waydroid.fake_gps` on each location update, including batched updates. The property supplies latitude, longitude, altitude, speed and bearing. Each generated fix gets the guest's current Unix time in milliseconds and Android's elapsed realtime in nanoseconds. Clearing the property restores the AOSP example position.

## Build

The driver source is the Android Open Source Project's `hardware/interfaces` tree at `android-13.0.0_r83` with [the Waydroid GNSS patch](gnss/waydroid-location.patch). To build in an Android 13 platform checkout, set `WAYDROID_STUFF` to the absolute path of this repository and run these commands from the platform root.

```sh
git -C hardware/interfaces apply "$WAYDROID_STUFF/gnss/waydroid-location.patch"
source build/envsetup.sh
for pair in aosp_x86_64:x86_64 aosp_arm64:arm64; do
    lunch "${pair%:*}-userdebug" || exit 1
    m android.hardware.gnss-service.example || exit 1
    install -m 755 "$ANDROID_PRODUCT_OUT/vendor/bin/hw/android.hardware.gnss-service.example" \
        "$WAYDROID_STUFF/gnss/${pair#*:}/bin/hw/" || exit 1
done
```

Run `python3 tools/package-gnss.py` in this repository to produce `.build/x86_64.zip` and `.build/arm64.zip`. The archives contain paths relative to the vendor partition and include the libraries shipped in 0.0.1. The packager fixes ZIP ordering, timestamps and permissions so identical inputs produce identical archives.

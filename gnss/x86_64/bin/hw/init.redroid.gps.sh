#!/vendor/bin/sh

# Create /dev/gnss1 device file if it doesn't exist
if [ ! -e /dev/gnss1 ]; then
    # Try to create a FIFO (named pipe) for /dev/gnss1
    # This allows writing location data that the GNSS HAL can read
    mknod /dev/gnss1 p
    chmod 666 /dev/gnss1
    chown system:system /dev/gnss1
fi

# Create directory for GPS location file
mkdir -p /data/vendor/gps
chmod 777 /data/vendor/gps

# Create initial location file if it doesn't exist
# Format: Fix,Provider,LatitudeDegrees,LongitudeDegrees,AltitudeMeters,SpeedMps,AccuracyMeters,BearingDegrees,UnixTimeMillis,SpeedAccuracyMps,BearingAccuracyDegrees,elapsedRealtimeNanos
if [ ! -f /data/vendor/gps/location.csv ]; then
    # Default location: Hangzhou, China
    echo "Fix,gps,30.281026818001678,120.01934876982831,1.60062531,0,5.0,0,0,1.0,90.0,0" > /data/vendor/gps/location.csv
    chmod 666 /data/vendor/gps/location.csv
fi

# Background daemon that reads from location file and writes to /dev/gnss1
# This allows runtime modification by writing to /data/vendor/gps/location.csv
(
    while true; do
        if [ -f /data/vendor/gps/location.csv ]; then
            # Read location from file
            LOCATION=$(cat /data/vendor/gps/location.csv)
            # Update timestamp (field 9)
            TIMESTAMP=$(date +%s)000
            # Replace timestamp in CSV (field 9)
            LOCATION_WITH_TIME=$(echo "$LOCATION" | awk -F',' -v ts="$TIMESTAMP" 'BEGIN{OFS=","} {$9=ts; print}')
            # Write to device file with required end marker (4 newlines)
            echo "${LOCATION_WITH_TIME}


" > /dev/gnss1
        fi
        sleep 1
    done
) &


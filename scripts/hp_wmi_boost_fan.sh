set -e 

TARGET_FILE="/sys/devices/platform/hp-wmi/hwmon/hwmon1/pwm1_enable"

if [ ! -f "$TARGET_FILE" ]; then
    echo "ERROR: Target file not found: $TARGET_FILE" >&2
    echo "Please ensure the path is correct and the hp-wmi kernel module is loaded." >&2
    exit 1
fi

current_value=$(tr -d '[:space:]' < "$TARGET_FILE")

echo "Current fan setting in $TARGET_FILE is: '$current_value'"

new_value=""
if [ "$current_value" = "0" ]; then
    new_value="2"
else
    new_value="0"
fi

echo "Changing fan setting to: '$new_value'"

if echo "$new_value" > "$TARGET_FILE"; then
    echo "Successfully changed fan setting to '$new_value'."
else
    echo "ERROR: Failed to write '$new_value' to $TARGET_FILE." >&2
    echo "Please make sure you are running this script with sudo privileges." >&2
    exit 1 
fi

exit 0


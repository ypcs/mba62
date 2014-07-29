# Helper scripts for setting backlight level

# All functions assume that checks for values have been done at lower level
# ie. if you're setting value, it assumes that you have validated the value
# and if you're validating value, it assumes that you have checked that device
# exists

debug() {
    if [ -n "${DEBUG}" ]
    then
        echo "D: $@" 1>&2
    fi
}

fail() {
    echo "E: $@" 1>&2
    exit 1
}

backlight_device() {
    CTRL_DIR="$1"
    if [ -d "${CTRL_DIR}" ]
    then
        RETVAL="0"
    else
        RETVAL="1"
    fi
    return "${RETVAL}"
}

# Get minimum value for backlight level
backlight_get_min() {
    CTRL_DIR="$1"
    MIN_VAL="0"
    debug "Minimum value: ${MIN_VAL}."
    echo "${MIN_VAL}"
}

# Get maximum value for backlight level, returns -1 if failure
backlight_get_max() {
    CTRL_DIR="$1"
    CTRL_FILE="${CTRL_DIR}/max_brightness"
    if [ -r "${CTRL_FILE}" ]
    then
        MAX_VAL="$(cat ${CTRL_FILE})"
        debug "Maximum value: ${MAX_VAL}."
        echo "${MAX_VAL}"
    else
        echo "-1"
    fi
}

# Check if given value is valid (0=ok, 1=small, 2=large)
backlight_validate_value() {
    CTRL_DIR="$1"
    VALUE="$2"
    RETVAL="0"

    MIN_VAL="$(backlight_get_min ${CTRL_DIR})"
    MAX_VAL="$(backlight_get_max ${CTRL_DIR})"
    if [ "${VALUE}" -gt "${MAX_VAL}" ]
    then
        debug "Value is larger than maximum (${VALUE} > ${MAX_VAL})."
        RETVAL="2"
    elif [ "${VALUE}" -lt "${MIN_VAL}" ]
    then
        debug "Value is smaller than minimum (${VALUE} < ${MIN_VAL})."
        RETVAL="1"
    fi
    return "${RETVAL}"
}

# Get current backlight level
backlight_get() {
    CTRL_DIR="$1"
    CTRL_FILE="${CTRL_DIR}/brightness"

    if [ -r "${CTRL_FILE}" ]
    then
        CUR_VAL="$(cat ${CTRL_FILE})"
        debug "Current value: ${CUR_VAL}."
        echo "${CUR_VAL}"
    else
        echo "-1"
    fi
}

# Set backlight level
backlight_set() {
    CTRL_DIR="$1"
    VALUE="$2"

    CTRL_FILE="${CTRL_DIR}/brightness"
    debug "Control file: ${CTRL_FILE}."

    if [ -w "${CTRL_FILE}" ]
    then
        CUR_VAL="$(backlight_get ${CTRL_DIR})"
        if [ "${VALUE}" = "${CUR_VAL}" ]
        then
            debug "Current value = value (${VALUE})."
            return 0
        fi
        debug "Setting value: ${VALUE}."
        echo "${VALUE}" >${CTRL_FILE}
    else
        debug "User can't write to control file (${CTRL_FILE})."
    fi
}

do_backlight() {
    BACKLIGHT_DEVICE="$1"
    VALUE="$2"

    debug "Check device existence..."
    backlight_device "${BACKLIGHT_DEVICE}" || fail "Control device ${BACKLIGHT_DEVICE} not found."
    debug "Validate values..."
    backlight_validate_value "${BACKLIGHT_DEVICE}" "${VALUE}" || fail "Invalid value: ${VALUE}."
    debug "Set value..."
    backlight_set "${BACKLIGHT_DEVICE}" "${VALUE}" || fail "Can't set backlight value."
}

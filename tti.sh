#!/bin/bash

: "${WRAP_COLUMN:=80}"
: "${FONT_FILE:=/usr/share/fonts/truetype/unifont/unifont.ttf}"
: "${FONT_SIZE:=25}"
: "${FILL_COLOR:=white}"
: "${BACKGROUND_COLOR:=black}"
: "${OBFUSCATE:=0}"
: "${NOISE_ROUNDS:=2}"
: "${NOISE_TYPE:=Impulse}"
: "${LINES_PER_10000PX:=2}"
: "${LINES_THICNESS:=1}"
: "${LINES_COLOR:=#ff0000}"
: "${SWIRL_DEGREES:=20}"
: "${WRAP_COLUMNS:=32}"
: "${STROKE_COLOR:=random}"
: "${STROKE_WIDTH:=0}"
: "${WAVE_AMPLITUDE:=5x128}"

#
# Generate Image
#
# $1 Text
# $2 Filename
#
function tti_generate_image() {
    local output_image imagemagick_options escaped i X_0 X_1 Y_0 Y_1
    if [[ $# -lt 1 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
    escaped=$(tti_adjust_text "$1")
    output_image="$2"
    if [[ "$BACKGROUND_COLOR" == "random" ]]; then
        BACKGROUND_COLOR=$(tti_get_random_hex_color)
    fi
    if [[ "$FILL_COLOR" == "random" ]]; then
        FILL_COLOR=$(tti_get_random_hex_color)
    fi
    if [[ "$UNDER_COLOR" == "random" ]]; then
        UNDER_COLOR=$(tti_get_random_hex_color)
    fi
    if [[ "$STROKE_COLOR" == "random" ]]; then
        STROKE_COLOR=$(tti_get_random_hex_color)
    fi
    imagemagick_options=(
        -font "$FONT_FILE"
        #-size "$IMAGE_SIZE"
        -pointsize "$FONT_SIZE"
        -fill "$FILL_COLOR"
        -background "$BACKGROUND_COLOR"
        #-undercolor "$UNDER_COLOR"
        #-stroke "$STROKE_COLOR"
        #-strokewidth "$STROKE_WIDTH"
        #-kerning "$KERNING"
        #-interword-spacing "$INTERWORD_SPACING"
        #-interline-spacing "$INTERLINE_SPACING"
        #-gravity "$GRAVITY"
        label:"$escaped"
        -flatten
    )
    if [[ "$OBFUSCATE" != 0 ]]; then
        imagemagick_options+=(
            -wave "$WAVE_AMPLITUDE"
            -rotate -90
            -wave "$WAVE_AMPLITUDE"
            -rotate +90
            -emboss 0x1
        )
        i=0
        while [[ "$i" -lt "$NOISE_ROUNDS" ]]; do
            imagemagick_options+=(+noise "$NOISE_TYPE")
            ((i = i + 1))
        done
    fi
    convert "${imagemagick_options[@]}" "$output_image"
    if [[ "$OBFUSCATE" == 0 ]]; then
        return;
    fi
    i=0
    tti_get_image_size "$output_image"
    lines_number=$((("$LINES_PER_10000PX" * "$WIDTH" * "$HEIGHT") / 10000))
    imagemagick_second_round=(
        "$output_image"
        -background "$BACKGROUND_COLOR"
        -flatten
    )
    while [[ "$i" -lt "$lines_number" ]]; do
        if [[ "$LINES_COLOR" == "random" ]]; then
            line_color=$(tti_get_random_hex_color)
        else
            line_color="$LINES_COLOR"
        fi
        if [[ $(tti_get_random_number "0" $(("$WIDTH" + "$HEIGHT"))) -gt       \
        "$WIDTH" ]]; then
            X_0=0
            X_1="$WIDTH"
            Y_0=$(tti_get_random_number "0" "$HEIGHT")
            Y_1=$(tti_get_random_number "0" "$HEIGHT")
        else
            X_0=$(tti_get_random_number "0" "$WIDTH")
            X_1=$(tti_get_random_number "0" "$WIDTH")
            Y_0=0
            Y_1="$HEIGHT"
        fi
        imagemagick_second_round+=(-stroke "$line_color" -strokewidth          \
        "$LINES_THICNESS")
        imagemagick_second_round+=(-draw "line $X_0,$Y_0 $X_1,$Y_1")
        ((i = i + 1))
    done
    imagemagick_second_round+=(-swirl "$SWIRL_DEGREES")
    convert "${imagemagick_second_round[@]}" "$output_image"
}

#
# Get Random Hex Color
#
function tti_get_random_hex_color() {
    local alphabet color char
    alphabet="0123456789ABCDEF"
    color=""
    for i in {0..5}; do
        char=${alphabet:$RANDOM % ${#alphabet}:1}
        color+=$char
    done
    printf "#%s" "$color"
}

#
# Get Image Size
#
# $1 Filename
#
function tti_get_image_size() {
    if [[ $# -eq 0 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
    if [[ ! -f "$1" ]]; then
        tti_exit "Error: image not found"
    fi
    WIDTH=$(identify -format '%w' "$1")
    HEIGHT=$(identify -format '%h' "$1")
}

#
# Get Random Number
#
# $1 Min
# $2 Max
#
function tti_get_random_number() {
    if [[ $# -le 1 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
    shuf -i "$1"-"$2" -n 1
}

#
# Wrap Text
#
# $1 Text
#
function tti_adjust_text() {
    if [[ $# -eq 0 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
    printf "%s" "$1" | sed -E 's/(\\|@|%)/\\\1/g' | fold -w "$WRAP_COLUMNS"
}

#
# Copy To Clipboard
#
# $1 Filename
#
function tti_copy_to_clipboard() {
    if [[ $# -eq 0 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
    xclip -selection clipboard -t image/jpeg -i "$1"
}

#
# Exit
#
# $1 Error Message
#
function tti_exit() {
    if [[ $# -eq 0 ]]; then
        echo "Error: undefined error."
    else
        echo "$1"
    fi
    exit 1
}

#
# Text To Image Main
#
# $1 Text
#
function tti_main() {
    local buffer output_image
    buffer=""
    while IFS= read -r line; do
        if [[ "$buffer" != "" ]]; then
            buffer+=$'\n'
        fi
        if [[ "$line" == "." ]]; then
            break
        fi
        buffer+="$line"
    done
    output_image="/tmp/$(date +%s%N | cut -b1-13).jpg"
    tti_generate_image "$buffer" "$output_image"
    tti_copy_to_clipboard "$output_image"
    if [[ -f "$output_image" ]]; then
        rm "$output_image"
    fi
}

tti_main "$@"

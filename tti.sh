#!/bin/bash

: "${WRAP_COLUMN:=80}"
#: "${FONT_FILE:=/usr/share/fonts/truetype/unifont/unifont.ttf}"
: "${FONT_SIZE:=25}"
: "${FILL_COLOR:=black}"
: "${BACKGROUND_COLOR:=white}"
: "${NOISE_ROUNDS:=2}"
: "${NOISE_TYPE:=Impulse}"
: "${LINES_PER_10000PX:=3}"
: "${LINES_THICNESS:=1}"
: "${LINES_COLOR:=black}"

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
    imagemagick_options=(
        #-font "$FONT_FILE"
        #-size "$IMAGE_SIZE"
        -pointsize "$FONT_SIZE"
        -fill "$FILL_COLOR"
        -background "$BACKGROUND_COLOR"
        #-undercolor "$UNDER_COLOR"
        #-stroke "$STROKE"
        #-strokewidth "$STROKE_WIDTH"
        #-kerning "$KERNING"
        #-interword-spacing "$INTERWORD_SPACING"
        #-interline-spacing "$INTERLINE_SPACING"
        #-gravity "$GRAVITY"
        label:"$escaped"
        #-emboss 0x1
        -flatten
    )
    i=0
    while [[ "$i" -lt "$NOISE_ROUNDS" ]]; do
        imagemagick_options+=(+noise "$NOISE_TYPE")
        ((i = i + 1))
    done
    convert "${imagemagick_options[@]}" "$output_image"
    i=0
    tti_get_image_size "$output_image"
    lines_number=$((("$LINES_PER_10000PX" * "$WIDTH" * "$HEIGHT") / 10000))
    echo $lines_number
    imagemagick_second_round=(
        "$output_image"
        -flatten
    )
    while [[ "$i" -lt "$lines_number" ]]; do
        X_0=$(tti_get_random_number "0" "$WIDTH")
        X_1=$(tti_get_random_number "0" "$WIDTH")
        Y_0=$(tti_get_random_number "0" "$HEIGHT")
        Y_1=$(tti_get_random_number "0" "$HEIGHT")
        imagemagick_second_round+=(-stroke "$LINES_COLOR" -strokewidth "$LINES_THICNESS")
        imagemagick_second_round+=(-draw "line $X_0,$Y_0 $X_1,$Y_1")
        ((i = i + 1))
    done
    imagemagick_second_round+=(-swirl 45)
    convert "${imagemagick_second_round[@]}" "$output_image"
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
    printf "%s" "$1" | sed -E 's/(\\|@|%)/\\\1/g' | fold -w 24
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
       # rm "$output_image"
       echo "OK"
    fi
}

tti_main "$@"

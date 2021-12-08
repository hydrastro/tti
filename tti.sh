#!/bin/bash

: "${WRAP_COLUMN:=80}"
: "${FONT_FILE:=}"
: "${FONT_SIZE:=20}"
: "${FILL_COLOR:=white}"
: "${BACKGROUND_COLOR:=black}"

#
# Generate Image
#
# $1 Text
# $2 Filename
#
function tti_generate_image() {
    local output_image imagemagick_options
    if [[ $# -lt 1 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
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
        label:"$1"
        -flatten
        "$output_image"
    )
    convert "${imagemagick_options[@]}"
}

#
# Wrap Text
#
# $1 Text
#
function tti_wrap_text() {
    if [[ $# -eq 0 ]]; then
        tti_exit "Error: missing argument(s) for ${FUNCNAME[0]}"
    fi
    printf "%s" "$1" | fold -w 80
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
    local buffer previous_line output_image
    buffer=""
    previous_line=""
    while IFS= read -r line; do
        if [[ "$buffer" != "" ]]; then
            buffer+=$'\n'
        fi
        buffer+="$line"
        if [[ "$line" == "" && "$previous_line" == "." ]]; then
            buffer=$(printf "%s" "$buffer" | head -n -1)
            break
        fi
        previous_line="$line"
    done
    output_image="/tmp/$(date +%s%N | cut -b1-13).jpg"
    tti_generate_image "$buffer" "$output_image"
    tti_copy_to_clipboard "$output_image"
    if [[ -f "$output_image" ]]; then
        rm "$output_image"
    fi
}

tti_main "$@"

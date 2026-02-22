#!/bin/bash
# ------------------------------------------------------------------------------
# Library: v2g
# Description: Video to GIF converter using the standard rgb8 baseline.
# ------------------------------------------------------------------------------

v2g_help() {
    cat << EOF
Usage: v2g <input_video> [output_gif] [options]

Description:
  Converts video files to GIFs using a clean, progressive scale.

Options:
  -h, --help       Show this help message and exit
  -q, --quality    Set quality preset (100, 80, 50, 25, 10)

Quality Presets:
  100   Best      (24fps, Original Res)
  80    High      (15fps, Original Res)
  50    Normal    (10fps, Original Res) *Default Baseline
  25    Low       (10fps, Max Width 480p, Compressed)
  10    Potato    (5fps,  Max Width 320p, Highly Compressed)
EOF
}

v2g_convert() {
    local input=""
    local output=""
    local quality="50"

    # Parse Arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                v2g_help
                return 0
                ;;
            -q|--quality)
                if [[ -z "$2" || "$2" == -* ]]; then
                    echo "Error: Argument for $1 is missing."
                    return 1
                fi
                quality="$2"
                shift 2
                ;;
            -*)
                echo "Error: Unknown option $1"
                v2g_help
                return 1
                ;;
            *)
                if [ -z "$input" ]; then
                    input="$1"
                elif [ -z "$output" ]; then
                    output="$1"
                fi
                shift
                ;;
        esac
    done

    # Validate Input
    if [ -z "$input" ]; then
        echo "Error: Input file required."
        return 1
    fi
    if [ ! -f "$input" ]; then
        echo "Error: File '$input' not found."
        return 1
    fi

    # Determine Output Name
    if [ -z "$output" ]; then
        output="${input%.*}.gif"
    fi
    if [[ "$output" != *.gif ]]; then
        output="${output}.gif"
    fi

    # Set Parameters progressively
    local fps
    local scale=""
    local lossy=""

    case "$quality" in
        100)
            fps="24"
            echo "Mode: 100% (Best) - Original Res, 24fps"
            ;;
        80)
            fps="15"
            echo "Mode: 80% (High) - Original Res, 15fps"
            ;;
        50)
            # THIS IS THE EXACT BASELINE COMMAND
            fps="10"
            echo "Mode: 50% (Normal) - Original Res, 10fps"
            ;;
        25)
            fps="10"
            scale="scale='min(480,iw)':-1"
            lossy="80"
            echo "Mode: 25% (Low) - Max 480p, 10fps, Compressed"
            ;;
        10)
            fps="5"
            scale="scale='min(320,iw)':-1"
            lossy="200"
            echo "Mode: 10% (Potato) - Max 320p, 5fps, Highly Compressed"
            ;;
        *)
            echo "Error: Invalid quality '$quality'."
            return 1
            ;;
    esac

    # Check Dependencies
    if ! command -v ffmpeg &> /dev/null || ! command -v gifsicle &> /dev/null; then
        echo "Error: ffmpeg and gifsicle are required."
        return 1
    fi

    echo "Converting '$input' to '$output'..."
    local start_time=$(date +%s)

    # Build Commands Safely using Arrays
    local ffmpeg_args=(ffmpeg -v error -stats -i "$input" -pix_fmt rgb8 -r "$fps")
    
    # Add scaling if defined (used in 25% and 10%)
    if [ -n "$scale" ]; then
        ffmpeg_args+=(-vf "$scale")
    fi
    
    # Finalize ffmpeg args for piping
    ffmpeg_args+=(-f gif -)

    # Build Gifsicle args
    local gifsicle_args=(-O3)
    if [ -n "$lossy" ]; then
        gifsicle_args+=(--lossy="$lossy")
    fi

    # Execute Conversion
    "${ffmpeg_args[@]}" | gifsicle "${gifsicle_args[@]}" > "$output"

    local status=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $status -eq 0 ]; then
        local size=$(du -h "$output" | cut -f1)
        echo -e "\nDone! Saved to '$output' ($size) in ${duration}s"
    else
        echo -e "\nError: Conversion failed."
        return 1
    fi
}

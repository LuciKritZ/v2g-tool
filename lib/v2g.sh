#!/bin/bash
# ------------------------------------------------------------------------------
# Library: v2g
# Description: Video to GIF converter with ultra-sharp quality presets.
# ------------------------------------------------------------------------------

v2g_help() {
    cat << EOF
Usage: v2g <input_video> [output_gif] [options]

Description:
  Converts video files to optimized, sharp GIFs.

Options:
  -h, --help       Show this help message and exit
  -q, --quality    Set quality preset (100, 80, 50, 25, 10)

Quality Presets:
  100   Pixel Perfect  (20fps, Original Res, No compression)
  80    High           (15fps, Max 1080p, Light compression)
  50    Medium         (12fps, Max 720p, Standard compression) *Default
  25    Low            (10fps, Max 480p, High compression)
  10    Potato         (5fps,  Max 320p, Aggressive compression)
EOF
}

v2g_convert() {
    local input=""
    local output=""
    local quality="50" # Default

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

    # Set Technical Parameters based on Quality Matrix
    local fps
    local scale
    local lossy_level

    case "$quality" in
        100)
            fps="20"
            scale="scale=-1:-1:flags=lanczos"
            lossy_level="0"
            echo "Mode: 100% (Pixel Perfect) - Original Res, 20fps"
            ;;
        80)
            fps="15"
            scale="scale='min(1080,iw)':-1:flags=lanczos"
            lossy_level="20" # Reduced from 30 for better sharpness
            echo "Mode: 80% (High Quality) - Max 1080p, 15fps"
            ;;
        50)
            fps="12"
            scale="scale='min(720,iw)':-1:flags=lanczos"
            lossy_level="50" # Reduced heavily from 80
            echo "Mode: 50% (Standard) - Max 720p, 12fps"
            ;;
        25)
            fps="10"
            scale="scale='min(480,iw)':-1:flags=lanczos"
            lossy_level="100"
            echo "Mode: 25% (Space Saver) - Max 480p, 10fps"
            ;;
        10)
            fps="5"
            scale="scale='min(320,iw)':-1:flags=lanczos"
            lossy_level="200"
            echo "Mode: 10% (Aggressive) - Max 320p, 5fps"
            ;;
        *)
            echo "Error: Invalid quality '$quality'."
            return 1
            ;;
    esac

    # 5. Check Dependencies
    if ! command -v ffmpeg &> /dev/null || ! command -v gifsicle &> /dev/null; then
        echo "Error: ffmpeg and gifsicle are required."
        return 1
    fi

    echo "Converting '$input' to '$output'..."
    local start_time=$(date +%s)

    # ==========================================================================
    # THE NEW HIGH-SHARPNESS FILTER GRAPH
    # ==========================================================================
    # a. scale & unsharp: Downscales, then adds a 5x5 Luma unsharp mask to restore crisp edges.
    # b. palettegen=stats_mode=diff: Focuses color fidelity on moving objects, ignoring static backgrounds.
    # c. paletteuse=dither=bayer: Uses a structured bayer grid instead of noisy/fuzzy random dithering.
    
    local sharpen="unsharp=5:5:0.5:3:3:0.0"
    local p_gen="palettegen=stats_mode=diff:max_colors=256"
    local p_use="paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle"
    
    local filter_graph="fps=$fps,$scale,$sharpen,split[s0][s1];[s0]$p_gen[p];[s1][p]$p_use"
    # ==========================================================================

    if [ "$lossy_level" -eq "0" ]; then
        ffmpeg -v error -stats -i "$input" -vf "$filter_graph" -f gif - | gifsicle -O3 > "$output"
    else
        ffmpeg -v error -stats -i "$input" -vf "$filter_graph" -f gif - | gifsicle -O3 --lossy="$lossy_level" > "$output"
    fi

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

#!/bin/bash
#
# Extract only critical warnings and errors from warning_summary.log
# into a separate log file with section info.

INPUT_LOG="results/warning_summary.log"
OUTPUT_LOG="results/critical_errors_only.log"

# Clear previous output
> "$OUTPUT_LOG"

current_section=""
found_any=0   # flag; set if found any errors/critical warnings

while IFS= read -r line; do
    # Detect section headers
    if [[ "$line" =~ ----SYNTHESIS---- ]]; then
        current_section="SYNTHESIS"
        echo "----$current_section----" >> "$OUTPUT_LOG"
        continue
    elif [[ "$line" =~ ----IMPLEMENTATION---- ]]; then
        current_section="IMPLEMENTATION"
        echo "----$current_section----" >> "$OUTPUT_LOG"
        continue
    fi

    # Only keep CRITICAL and ERROR lines
    if [[ "$line" =~ CRITICAL|ERROR ]]; then
        found_any=1
        # Determine tag
        if [[ "$line" =~ CRITICAL ]]; then
            tag="[CRITICAL_WARNING]"
        else
            tag="[ERROR]"
        fi
        echo "$tag $line" >> "$OUTPUT_LOG"
    fi
done < "$INPUT_LOG"

if [[ $found_any -eq 1 ]]; then
    echo "Filtered critical warnings and errors written to $OUTPUT_LOG"
else
    echo "No critical warnings or errors found in $INPUT_LOG"
fi

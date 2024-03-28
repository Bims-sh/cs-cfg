#!/bin/bash

# Echo GitHub link
echo "Script source: https://github.com/Bims-sh/cs-cfg/enable-shadows.sh"

# Check if file path is provided
if [ -z "$1" ]; then
    echo "Please provide the file path as an argument."
    exit 1
fi

filePath=$1

# Check for read-only
if [ ! -w "$filePath" ]; then
    echo "The file is read-only. Exiting..."
    exit
fi

# Backup file
cp "$filePath" "${filePath}.bak"
echo "A backup has been created at ${filePath}.bak"

# Read file content
content=$(cat "$filePath")

# Edit the file content
newContent=$(echo "$content" | sed 's/"setting.csm_max_shadow_dist_override"[[:space:]]\+"[0-9]\+"/"setting.csm_max_shadow_dist_override"		"560"/')
newContent=$(echo "$newContent" | sed 's/"setting.lb_shadow_texture_width_override"[[:space:]]\+"[0-9]\+"/"setting.lb_shadow_texture_width_override"		"518"/')
newContent=$(echo "$newContent" | sed 's/"setting.lb_shadow_texture_height_override"[[:space:]]\+"[0-9]\+"/"setting.lb_shadow_texture_height_override"		"518"/')
newContent=$(echo "$newContent" | sed 's/"setting.lb_enable_shadow_casting"[[:space:]]\+"[0-9]\+"/"setting.lb_enable_shadow_casting"		"1"/')

# Save the modified content
echo "$newContent" > "$filePath"

# Make the file readonly
chmod 400 "$filePath"

# Remove backup file
rm "${filePath}.bak"

# Echo message
echo "The file has been placed at $filePath and the modifications were successful."

#!/bin/bash

# Get all default menu bar items as JSON array of strings
items=$(sketchybar --query default_menu_items)

# Parse and add each as an alias
echo "$items" | jq -r '.[]' | while read -r item; do
  # Generate a unique name for the alias (e.g., alias_<item>)
  name="alias_$(echo "$item" | tr ', ' '__' | tr -cd '[:alnum:]_')"
  # Add the alias to SketchyBar at position 0 (change as needed)
  sketchybar --add alias "$item" right 
done

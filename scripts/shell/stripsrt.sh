#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "This script takes an srt file and outputs a file containing"
   echo " the subtitles alone separated by a newline."
   echo
   echo "Syntax: stripsrt [-i|h]"
   echo "options:"
   echo "i     The path of input file to be stripped."
   echo "h     Print this Help."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

############################################################
# Process the input options. Add options as needed.        #
############################################################

# function to count words
count_words() {
  # if word count of line is greater than 2 return true
  wordcount=$(wc -w <<< "$1")
  if [[ $wordcount -gt 2 ]]; then
    return 0
  fi
  return 1
}

# Get the options
while getopts ":hi:" opt; do
   case $opt in
      h) # display Help
         Help
         exit;;
      i) # Enter a filename
         filepath=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

# if filepath is missing print missing -i (input)
if [ -z "$filepath" ]; then
  echo "Missing -i" >&2
  exit 1
fi

# make sure file exists
if [ ! -f "$filepath" ]; then
  echo "File does not exist."
  exit 1
fi

echo "stripping srt file: $filepath"

# create output file variable
outfile="$filepath.stripped"
# empty output file if exists
true > "$outfile"

# remove in place macOS
sed -i '' -e 's/-//g' "$filepath"
sed -i '' -e 's/<i>//g' "$filepath"
sed -i '' -e 's/<\/i>//g' "$filepath"
# delete all strings between brackets including brackets
sed -i '' -e "s/[{][^)]*[}]//g" "$filepath"

# remove in place GNU
# sed -i 's/\b(-|<i>|<\/i>)\b//g' "$filepath"

# read file by line
while read -r line
do
  # if line begins with letter then we want to output
  if [[ $line =~ ^[A-Za-z] ]] ; then
    read -r nextline
    # if next line starts with letter then combine both lines
    if [[ $nextline =~ ^[A-Za-z] ]] ; then
      # remove '\n' from $line and combine with nextline
      newline="${line//[$'\t\r\n']} $nextline"
      if count_words "$newline"; then
        echo "$newline" >> "$outfile"
      fi
    else
      # if count_words() returns true output line to output file
      if count_words "$line" ; then
        echo "$line" >> "$outfile"
      fi
    fi
  fi
done < "$filepath"

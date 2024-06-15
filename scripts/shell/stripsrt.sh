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

if [ -z "$filepath" ]; then
  echo "Missing -i" >&2
  exit 1
else
  # make sure file exists
  if [ ! -f "$filepath" ]; then
    echo "File does not exist."
    exit 1
  fi

  echo "stripping srt file: $filepath"

  # create output file variable
  outfile="$filepath.out"
  # empty output file if exists
  echo "" > "$outfile"

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
        my_var="$line $nextline"
        # this command works to concat the two lines but throws an error
        ${my_var//$'\n'/} >> "$outfile" 2>/dev/null
      else
        echo "$line" >> "$outfile"
      fi
    fi
  done < "$filepath"
fi

#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo
   echo "This script takes an tsv filepath, title and language as input"
   echo "and uploads it to your talkliketv database."
   echo
   echo "You must first export your postgres connection string in form: "
   echo "export TALKTV_DB_DSN=postgres://<user>:<password>@localhost/<host>?sslmode=disable"
   echo
   echo "Syntax: uploadcsv [-f|t|l|h]"
   echo "options:"
   echo "f     The path of input file to be uploaded."
   echo "t     The title of the phrases to be uploaded."
   echo "l     The language of phrases that english is translated from."
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

# function to make hint string
make_hint_string() {
  hintstring=""
  IFS=' ' read -r -a array <<< "$1"
  for word in "${array[@]}"; do
    punctuation=false
    hintstring=$hintstring"${word:0:1}"
    if [ "${word:0:1}" = '¡' ] || [ "${word:0:1}" = '¿' ]; then
      punctuation=true
    fi
    for (( i=1; i<${#word}; i++ )); do
      if [ $punctuation = true ]; then
        hintstring+="${word:$i:1}"
        punctuation=false
      elif [[ "${word:$i:1}" == [A-Za-záéíóúüñç] ]]; then
        hintstring+="_"
      else
        hintstring+="${word:$i:1}"
      fi

    done
  hintstring+=" "
  done
  echo $hintstring
}

# Get the options
while getopts ":hf:t:l:" opt; do
   case $opt in
      h) # display Help
         Help
         exit;;
      f) # Enter a filepath
         filepath=$OPTARG;;
      t) # Enter a title
         title=$OPTARG;;
      l) # Enter a language
         language=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [ -z "$filepath" ]; then
  echo "Missing -f" >&2
  exit 1
elif [ -z "$title" ]; then
  echo "Missing -t" >&2
  exit 1
elif [ -z "$language" ]; then
  echo "Missing -l" >&2
  exit 1
fi

# make sure file exists
if [ ! -f "$filepath" ]; then
  echo "File does not exist."
  exit 1
fi

echo "uploading file: $filepath"

# get the language id to insert with nest query
language_id=$(psql -qtAX --command="SELECT id From languages WHERE language = '$language';" postgres://talktv:pa55word@localhost/talktv?sslmode=disable)

# count number of rows to insert into movies table
row_count=$(grep -c ^ "$filepath")

# insert movie and capture movie id to insert values
movie_id=$(psql -qtAX --command="INSERT INTO movies (title, language_id, num_subs) VALUES ('$title', '$language_id', '$row_count') RETURNING id" postgres://talktv:pa55word@localhost/talktv?sslmode=disable)
echo "movie_id: $movie_id"

# read file by line
while read -r line
do
  # remove return at end of line
  line=${line//$'\r'/}
  IFS=$'\t' read -r -a array <<< "$line"

  # replace single apostrophes with two
  # this is necessary for insert statement to postgres db
  array0=${array[0]//[\']/\'\'}
  array1=${array[1]//[\']/\'\'}

  # create hint strings from phrases
  var0=$(make_hint_string "$array0")
  var1=$(make_hint_string "$array1")

  # create values string for insert statment
  values_string="'$array0', '$array1', '$var0', '$var1', $movie_id"
  # shellcheck disable=SC2027
  psql -qtAX --command="INSERT INTO phrases (phrase, translates, phrase_hint, translates_hint, movie_id) VALUES ( $values_string )" postgres://talktv:pa55word@localhost/talktv?sslmode=disable
done <"$filepath"
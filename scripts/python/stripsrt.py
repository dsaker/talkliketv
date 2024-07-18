#!/usr/bin/env python3

import re
import argparse


def replace(line_in):
    # remove square brackets and contents
    line_in = re.sub("\[.*?\]", "", line_in)
    # remove brackets and contents
    line_in = re.sub("{.*?}", "", line_in)
    # replace unneeded characters and strip trailing and beginning white space
    line_in = line_in.replace("-", "").replace("<i>", "").replace("</i>", "").replace("[]", "").replace("-", "").strip()
    # replace multiple white spaces with one
    ' '.join(line_in.split())
    # if length of line is greater than one output to output file
    if len(line_in.split()) > 1:
        output.write(line_in + "\n")


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--Input", help="SRT filepath to strip (must be string)")
    args = parser.parse_args()
    print("\nstripping srt file: ", args.Input)
    filepath = args.Input

    with open(filepath, 'r') as file:
        with open(filepath + ".out", 'w') as output:
            # skip first line because it has space before it which doesn't catch it if it is digit
            next(file)
            # go through file line by line
            for line in file:
                # skip if line is newline or begins with digit
                if line[0].isdigit() or line[0] == "\n":
                    continue
                # skip descriptions
                if line.startswith("[") and line.endswith("]\n"):
                    continue
                else:
                    new_line = line
                    next_line = next(file)
                    # if next line following subtitle is not new line it is more dialogue so combine it
                    if next_line != "\n":
                        new_line = new_line.replace("\n", " ")
                        new_line += next_line
                        replace(new_line)
                    else:
                        replace(new_line)

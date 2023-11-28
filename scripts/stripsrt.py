#!/usr/bin/env python3

import re
import argparse


def replace(line_in):
    line_in = re.sub("\[.*?\]", "", line_in)
    line_in = re.sub("{.*?}", "", line_in)
    line_in = line_in.replace("-", "").replace("<i>", "").replace("</i>", "").replace("[]", "").replace("-", "").strip()
    ' '.join(line_in.split())  # replace multiple white spaces with one
    if len(line_in.split()) > 1:
        output.write(line_in + "\t")


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--Input", help="SRT filepath to strip (must be string)")
    args = parser.parse_args()
    print("\nstripping srt file: ", args.Input)
    filepath = args.Input

    with open(filepath, 'r') as file:
        with open(filepath + ".out", 'w') as output:
            for line in file:
                if not line[0].isdigit() and not line[0] == "\n":
                    if line.startswith("[") and line.endswith("]\n"):
                        continue
                    else:
                        new_line = line
                        next_line = next(file)
                        if next_line != "\n":
                            new_line = new_line.replace("\n", " ")
                            new_line += next_line
                            replace(new_line)
                        else:
                            replace(new_line)

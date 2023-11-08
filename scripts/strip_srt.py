import re


def replace(line_in):
    line_in = re.sub("\[.*?\]", "", line_in)
    line_in = re.sub("{.*?}", "", line_in)
    line_in = line_in.replace("-", "").replace("<i>", "").replace("</i>", "").replace("[]", "").replace("-", "").strip()
    if len(line_in.split()) > 1:
        output.write(line_in + "\t")


if __name__ == '__main__':

    # filepath = "/Users/dustysaker/Downloads/miss.adrenaline.subs/spanish/Miss.Adrenaline.A.Tale.of.Twins.S01E03.SPANISH.WEBRip.NF.spa.srt"
    # outpath = "/Users/dustysaker/Downloads/miss.adrenaline.subs/spanish/stripped/MissAdrenaline_s01e03.spa.txt"

    filepath = "/Users/dustysaker/Downloads/miss.adrenaline.subs/english/Miss.Adrenaline.A.Tale.of.Twins.S01E03.SPANISH.WEBRip.NF.en.srt"
    outpath = "/Users/dustysaker/Downloads/miss.adrenaline.subs/english/stripped/MissAdrenaline_s01e03.eng.txt"

    with open(filepath, 'r') as input:
        with open(outpath, 'w') as output:
            for line in input:
                if not line[0].isdigit() and not line[0] == "\n":
                    if line.startswith("[") and line.endswith("]\n"):
                        continue
                    else:
                        new_line = line
                        next_line = next(input)
                        if next_line != "\n":
                            new_line = new_line.replace("\n", " ")
                            new_line += next_line
                            replace(new_line)
                        else:
                            replace(new_line)

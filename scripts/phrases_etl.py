import psycopg2
import csv

conn = psycopg2.connect("postgres://talktv:pa55word@localhost/talktv?sslmode=disable")
cur = conn.cursor()
with open('/Users/dustysaker/Downloads/Miss.Adrenaline.s01e01 - MissAdrenalineS01E01.csv', 'r') as f:
    reader = csv.reader(f)
    # row_count = sum(1 for row in reader)
    # print(row_count)
    # cur.execute(
    #     "INSERT INTO movies (title, num_subs) VALUES ('MissAdrenalineS01E01', %s)", [row_count]
    # )
    for idx, row in enumerate(reader):
        # phrase = row[1].replace('¡', "").replace("!", "").replace(u"\u00BF", "").replace("?", "").replace(".", "").strip()
        hintString = ""
        words = row[1].strip().split(" ")
        for word in words:
            punctuation = False;
            hintString += word[0]
            if word[0] in ['¡', u"\u00BF"]:
                punctuation = True
            for i in range(1, len(word)):
                if punctuation:
                    hintString += word[i]
                    punctuation = False
                elif word[i].isalpha():
                    hintString += " "
                else:
                    hintString += word[i]
            hintString += " "
        # print(row[1].strip())
        # print(hintString.strip())
        row.append(hintString.strip())
        cur.execute(
            "INSERT INTO phrases (movie_id, phrase, translates, hint) VALUES (1, %s, %s, %s)", row
        )
    conn.commit()

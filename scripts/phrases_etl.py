import psycopg2
import csv
import argparse
import os


def upload_file(file, language, title):
    conn = psycopg2.connect(os.environ['TALKTV_DB_DSN'])
    cur = conn.cursor()
    cur.execute(
        "SELECT id FROM languages WHERE language = %s", [language]
    )
    language_id = cur.fetchone()[0]
    with open(file, 'r') as f:
        reader = csv.reader(f)
        row_count = sum(1 for _ in reader)
        print(row_count)
        cur.execute(
            "INSERT INTO movies (title, language_id, num_subs) VALUES (%s, %s, %s) RETURNING id",
            (title, language_id, row_count)
        )
        movie_id = cur.fetchone()[0]
        print(movie_id)
        f.seek(0)
        for idx, row in enumerate(reader):
            hintstring = ""
            # words = row[1].replace("   ", " ").replace("  ", " ").replace("…", "").strip().split(" ")
            words = row[1].strip().split(" ")
            # print(words)
            for word in words:
                # print(word)
                punctuation = False
                hintstring += word[0]
                if word[0] in ['¡', u"\u00BF"]:
                    punctuation = True
                for i in range(1, len(word)):
                    if punctuation:
                        hintstring += word[i]
                        punctuation = False
                    elif word[i].isalpha():
                        hintstring += " "
                    else:
                        hintstring += word[i]
                hintstring += " "
            row.append(hintstring.strip())
            row.insert(0, movie_id)
            print(row)
            cur.execute(
                "INSERT INTO phrases (movie_id, phrase, translates, hint) VALUES (%s, %s, %s, %s)", row
            )
        conn.commit()


if __name__ == '__main__':
    desc = "a program to insert phrases into talk like tv db"

    parser = argparse.ArgumentParser(description=desc, prog="phrases_etl.py")
    parser.add_argument("-f", "--filepath", help="csv file to upload", required=True)
    parser.add_argument("-t", "--title", help="title to insert into db", required=True)
    parser.add_argument("-l", "--language",
                        help="origin language of the file",
                        required=True,
                        choices=['Spanish', 'French'])
    args = vars(parser.parse_args())

    upload_file(args['filepath'], args['language'], args['title'])

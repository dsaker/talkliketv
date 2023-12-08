#!/usr/bin/env python3

import psycopg2
import csv
import argparse
import os


def makehintstring(solution):
    hintstring = ""
    words = ' '.join(solution.split())
    words = words.split(" ")
    for word in words:
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
    return hintstring


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
            row.append(makehintstring(row[0]).strip())
            row.append(makehintstring(row[1]).strip())
            row.append(movie_id)
            cur.execute(
                "INSERT INTO phrases (phrase, translates, phrase_hint, translates_hint, movie_id) "
                "VALUES (%s, %s, %s, %s, %s)", row
            )
        conn.commit()


if __name__ == '__main__':
    desc = "a program to insert phrases into talk like tv db"

    parser = argparse.ArgumentParser(description=desc, prog="uploadcsv.py")
    parser.add_argument("-f", "--filepath", help="csv file to upload", required=True)
    parser.add_argument("-t", "--title", help="title to insert into db", required=True)
    parser.add_argument("-l", "--language",
                        help="origin language of the file",
                        required=True,
                        choices=['Spanish', 'French'])
    args = vars(parser.parse_args())

    upload_file(args['filepath'], args['language'], args['title'])

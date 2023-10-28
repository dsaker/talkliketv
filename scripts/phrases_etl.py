import psycopg2
import csv

conn = psycopg2.connect("postgres://talktv:pa55word@localhost/talktv?sslmode=disable")
cur = conn.cursor()
with open('/Users/dustysaker/Downloads/Miss.Adrenaline.s01e01 - MissAdrenalineS01E01.csv', 'r') as f:
    reader = csv.reader(f)
    for idx, row in enumerate(reader):
        cur.execute(
            "INSERT INTO phrases (phrase, translates) VALUES (%s, %s)", row
        )
conn.commit()

import csv
import sqlite3
import glob
import os

# This python program iterate thousands of folders
# Each folder has 15-20 different csv tables
# The program put create and combine different csv tables into single database file

# iterate through file in a directory
def do_directory(dirname, db):
    for filename in glob.glob(os.path.join(dirname, '*.csv')):
        do_file(filename, db)

# create / insert tables to existing database
def do_file(filename, db):
        with open(filename) as f:
            with db:
                data = csv.DictReader(f)
                cols = data.fieldnames
                #print(cols)
                table=os.path.splitext(os.path.basename(filename))[0]
                #print(table)

                #sql = 'drop table if exists "{}"'.format(table)
                #db.execute(sql)

                # create table if such table not exist
                sql = 'create table if not exists "{table}" ( {cols} )'.format(
                    table=table,
                    cols=','.join('"{}"'.format(col) for col in cols))
                db.execute(sql)

                # insert new entry if the table already exist
                sql = 'insert into "{table}" values ( {vals} )'.format(
                    table=table,
                    vals=','.join('?' for col in cols))
                db.executemany(sql, (list(map(row.get, cols)) for row in data))

# main function iterate through the unzip folders
# specify the database to connect in "sqlite3.connect()"
if __name__ == '__main__':
    conn = sqlite3.connect('101055.db')
    for root, dirs, files in os.walk('.'):
        for dirc in dirs:
            do_directory(os.path.join(root, dirc), conn)

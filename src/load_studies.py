'''
Created on Apr 9, 2013

@author: dvanassc
'''

import sqlite3 as sqllite
import csv

CONN = sqllite.connect("../db/weblogs.db")
CONN.text_factory = str
CURSOR = CONN.cursor()

def load_studies():
  print 'Loading studies...'
  CURSOR.execute('DROP TABLE IF EXISTS studies')
  CURSOR.execute("""CREATE TABLE studies
                    (id INTEGER PRIMARY KEY, name TEXT, release_date TEXT) 
                 """)
  with open('../studies/studies.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter='\t')
    studies = [(int(i['study']), i['name'], i['release_date']) for i in dr]
  CURSOR.executemany("INSERT INTO studies (id, name, release_date) VALUES (?, ?, ?)", studies)
  CONN.commit()

def load_classifications():
  print 'Loading classifications...'
  CURSOR.execute('DROP INDEX IF EXISTS classification_studies_fk')
  CURSOR.execute('DROP TABLE IF EXISTS classifications')
  CURSOR.execute("""CREATE TABLE classifications
                    (id INTEGER PRIMARY KEY, code TEXT, description TEXT, study_id INTEGER,
                    FOREIGN KEY(study_id) REFERENCES studies(id)) 
                 """)
  CURSOR.execute('CREATE INDEX classification_studies_fk ON classifications (study_id)')
  with open('../studies/classifications.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter='\t')
    classifications = [(i['code'], i['description'], int(i['study'])) for i in dr]
  CURSOR.executemany("INSERT INTO classifications (code, description, study_id) VALUES (?, ?, ?)", classifications)
  CONN.commit()

def load_subjects():
  print 'Loading subjects...'
  CURSOR.execute('DROP INDEX IF EXISTS subject_studies_fk')
  CURSOR.execute('DROP TABLE IF EXISTS subjects')
  CURSOR.execute("""CREATE TABLE subjects
                    (id INTEGER PRIMARY KEY, subject TEXT, study_id INTEGER,
                    FOREIGN KEY(study_id) REFERENCES studies(id)) 
                 """)
  CURSOR.execute('CREATE INDEX subject_studies_fk ON subjects (study_id)')
  with open('../studies/subjects.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter='\t')
    subjects = [(i['subject'], int(i['study'])) for i in dr]
  CURSOR.executemany("INSERT INTO subjects (subject, study_id) VALUES (?, ?)", subjects)
  CONN.commit()

def main():
  try:
    load_studies()
    load_classifications()
    load_subjects()
  except sqllite.Error, e:
    print "Error %s:" % e.args[0]
  finally:
    if CONN:
      CONN.commit()
      CONN.close()
    
if __name__ == '__main__':
  main()

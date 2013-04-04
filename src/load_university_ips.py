'''
Created on Apr 3, 2013

@author: dvanassc
'''

import sqlite3 as sqllite
import csv

CONN = sqllite.connect("../db/weblogs.db")
CONN.text_factory = str
CURSOR = CONN.cursor()

def load_universities():
  print 'Loading universities...'
  CURSOR.execute('DROP TABLE IF EXISTS universities')
  CURSOR.execute("""CREATE TABLE universities
                    (id INTEGER PRIMARY KEY, name TEXT, city TEXT, state TEXT, country TEXT) 
                 """)
  with open('../locations/universities.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter='\t')
    universities = [(int(i['id']), i['name'], i['city'], i['state'], i['country']) for i in dr]
  CURSOR.executemany("INSERT INTO universities (id, name, city, state, country) VALUES (?, ?, ?, ?, ?)", universities)
  CURSOR.execute("UPDATE universities SET state = null WHERE state = '(null)'")
  CONN.commit()

def load_university_ips():
  print 'Loading university ips...'
  CURSOR.execute('DROP INDEX IF EXISTS university_ips_idx')
  CURSOR.execute('DROP INDEX IF EXISTS university_ips_fk')
  CURSOR.execute('DROP TABLE IF EXISTS university_ips')
  CURSOR.execute("""CREATE TABLE university_ips
                    (id INTEGER PRIMARY KEY, university_id INTEGER, abyte INTEGER, bbyte INTEGER, cbyte INTEGER, dbyte1 INTEGER, dbyte2 INTEGER,
                    FOREIGN KEY(university_id) REFERENCES university(id)) 
                 """)
  CURSOR.execute('CREATE INDEX university_ips_idx ON university_ips (abyte, bbyte, cbyte)')
  CURSOR.execute('CREATE INDEX university_ips_fk ON university_ips (university_id)')
  with open('../locations/university_ips.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter='\t')
    ips = [(int(i['university_id']),int(i['abyte']),int(i['bbyte']),int(i['cbyte']),int(i['dbyte1']),int(i['dbyte2'])) for i in dr]
  CURSOR.executemany("INSERT INTO university_ips (university_id, abyte, bbyte, cbyte, dbyte1, dbyte2) VALUES (?, ?, ?, ?, ?, ?)", ips)
  CONN.commit()

def main():
  try:
    load_universities()
    load_university_ips()
  except sqllite.Error, e:
    print "Error %s:" % e.args[0]
  finally:
    if CONN:
      CONN.commit()
      CONN.close()
    
if __name__ == '__main__':
  main()

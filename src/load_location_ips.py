'''
Created on Apr 3, 2013

@author: dvanassc
'''

import sqlite3 as sqllite
import csv
import urllib

CONN = sqllite.connect("../db/weblogs.db")
CONN.text_factory = str
CURSOR = CONN.cursor()

def load_countries():
  print 'Loading countries...'
  CURSOR.execute('DROP TABLE IF EXISTS countries')
  CURSOR.execute("""CREATE TABLE countries
                    (id INTEGER PRIMARY KEY, name TEXT, abbr TEXT) 
                 """)
  with open('../locations/hip_countries.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter=',')
    countries = [(int(i['id']), i['name'], i['abbr']) for i in dr]
  CURSOR.executemany("INSERT INTO countries (id, name, abbr) VALUES (?, ?, ?)", countries)
  CONN.commit()

def load_cities():
  print 'Loading cities...'
  CURSOR.execute('DROP INDEX IF EXISTS cities_name_idx')
  CURSOR.execute('DROP INDEX IF EXISTS cities_country_fk')
  CURSOR.execute('DROP TABLE IF EXISTS cities')
  CURSOR.execute("""CREATE TABLE cities
                    (id INTEGER PRIMARY KEY, name TEXT, lat REAL, lng REAL, state TEXT, country_id INTEGER,
                    FOREIGN KEY(country_id) REFERENCES countries (id))
                 """)
  CURSOR.execute('CREATE INDEX cities_country_fk ON cities (country_id)')
  CURSOR.execute('CREATE INDEX cities_name_idx ON cities (name)')
  with open('../locations/hip_cities.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter='\t')
    cities = [(int(i['city']), int(i['country']), urllib.unquote(i['name']), float(i['lat']), float(i['lng']), i['state']) for i in dr]
  CURSOR.executemany("INSERT INTO cities (id, country_id, name, lat, lng, state) VALUES (?, ?, ?, ?, ?, ?)", cities)
  CONN.commit()

def load_country_ips():
  print 'Loading country ips...'
  CURSOR.execute('DROP INDEX IF EXISTS country_ips_idx')
  CURSOR.execute('DROP INDEX IF EXISTS country_ips_country_fk')
  CURSOR.execute('DROP TABLE IF EXISTS country_ips')
  CURSOR.execute("""CREATE TABLE country_ips
                    (id INTEGER PRIMARY KEY, long_ip INTEGER, country_id INTEGER,
                    FOREIGN KEY(country_id) REFERENCES countries (id)) 
                 """)
  CURSOR.execute('CREATE INDEX country_ips_country_fk ON country_ips (country_id)')
  CURSOR.execute('CREATE INDEX country_ips_idx ON country_ips (long_ip)')
  with open('../locations/hip_ip4_country.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter=',')
    ips = []
    cnt = 0
    for i in dr:
      ips.append((long(i['long_ip']), int(i['country'])))
      cnt += 1
      if cnt > 0 and cnt % 50000 == 0:
        CURSOR.executemany("INSERT INTO country_ips (long_ip, country_id) VALUES (?, ?)", ips)
        ips = []
  CURSOR.executemany("INSERT INTO country_ips (long_ip, country_id) VALUES (?, ?)", ips)
  CONN.commit()

def load_city_ips():
  print 'Loading city ips...'
  CURSOR.execute('DROP INDEX IF EXISTS city_ips_idx')
  CURSOR.execute('DROP INDEX IF EXISTS city_ips_city_fk')
  CURSOR.execute('DROP TABLE IF EXISTS city_ips')
  CURSOR.execute("""CREATE TABLE city_ips
                    (id INTEGER PRIMARY KEY, long_ip INTEGER, city_id INTEGER,
                    FOREIGN KEY(city_id) REFERENCES cities (id)) 
                 """)
  CURSOR.execute('CREATE INDEX city_ips_city_fk ON city_ips (city_id)')
  CURSOR.execute('CREATE INDEX city_ips_idx ON city_ips (long_ip)')
  with open('../locations/hip_ip4_city_lat_lng.csv','rb') as fin:
    dr = csv.DictReader(fin, delimiter=',')
    ips = []
    cnt = 0
    for i in dr:
      CURSOR.execute("select id from cities where name = ?", (urllib.unquote(i['city']),))
      city = CURSOR.fetchone()
      if city is not None:
        ips.append((long(i['long_ip']), int(city[0])))
        cnt += 1
        if cnt > 0 and cnt % 50000 == 0:
          CURSOR.executemany("INSERT INTO city_ips (long_ip, city_id) VALUES (?, ?)", ips)
          ips = []
  CURSOR.executemany("INSERT INTO city_ips (long_ip, city_id) VALUES (?, ?)", ips)
  CONN.commit()

def main():
  try:
    load_countries()
    load_cities()
    load_country_ips()
    load_city_ips()
  except sqllite.Error, e:
    print "Error %s:" % e.args[0]
  finally:
    if CONN:
      CONN.commit()
      CONN.close()
    
if __name__ == '__main__':
  main()

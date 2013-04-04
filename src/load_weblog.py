'''
Created on Apr 3, 2013

@author: dvanassc
'''

import os
import re
import sqlite3 as sqllite

CONN = sqllite.connect("../db/weblogs.db")
CONN.text_factory = str
CURSOR = CONN.cursor()

def init_database():
  CURSOR.execute('DROP INDEX IF EXISTS weblog_searches_idx1')
  CURSOR.execute('DROP TABLE IF EXISTS weblog_searches')
  CURSOR.execute("""CREATE TABLE weblog_searches
                    (id INTEGER PRIMARY KEY, timestamp TEXT, ip TEXT, abyte INTEGER, bbyte INTEGER, cbyte INTEGER, dbyte INTEGER, url TEXT, referrer TEXT, browser_type TEXT, search_terms TEXT) 
                 """)
  CURSOR.execute('CREATE INDEX weblog_searches_idx1 ON weblog_searches (abyte, bbyte, cbyte, dbyte)')
  
  CURSOR.execute('DROP INDEX IF EXISTS weblog_homepages_idx1')
  CURSOR.execute('DROP TABLE IF EXISTS weblog_homepages')
  CURSOR.execute("""CREATE TABLE weblog_homepages
                    (id INTEGER PRIMARY KEY, timestamp TEXT, ip TEXT, abyte INTEGER, bbyte INTEGER, cbyte INTEGER, dbyte INTEGER, url TEXT, referrer TEXT, browser_type TEXT, study INTEGER) 
                 """)
  CURSOR.execute('CREATE INDEX weblog_homepages_idx1 ON weblog_homepages (abyte, bbyte, cbyte, dbyte)')
  
  CURSOR.execute('DROP INDEX IF EXISTS weblog_downloads_idx1')
  CURSOR.execute('DROP TABLE IF EXISTS weblog_downloads')
  CURSOR.execute("""CREATE TABLE weblog_downloads
                    (id INTEGER PRIMARY KEY, timestamp TEXT, ip TEXT, abyte INTEGER, bbyte INTEGER, cbyte INTEGER, dbyte INTEGER, url TEXT, referrer TEXT, browser_type TEXT, study INTEGER, format TEXT) 
                 """)
  CURSOR.execute('CREATE INDEX weblog_downloads_idx1 ON weblog_downloads (abyte, bbyte, cbyte, dbyte)')
  
  CONN.commit()

def load_search(searches):
  print 'Loading searches...'
  CURSOR.executemany("INSERT INTO weblog_searches (timestamp, ip, abyte, bbyte, cbyte, dbyte, url, referrer, browser_type, search_terms) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", searches)
  CONN.commit()

def load_homepage(homepages):
  print 'Loading homepages...'
  CURSOR.executemany("INSERT INTO weblog_homepages (timestamp, ip, abyte, bbyte, cbyte, dbyte, url, referrer, browser_type, study) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", homepages)
  CONN.commit()

def load_download(downloads):
  print 'Loading downloads...'
  CURSOR.executemany("INSERT INTO weblog_downloads (timestamp, ip, abyte, bbyte, cbyte, dbyte, url, referrer, browser_type, study, format) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", downloads)
  CONN.commit()

def extract(f):
  print 'Extracting ' + f + '...'
  search_p = re.compile(r'^([0-9]{8}-[0-9]{2}:[0-9]{2})\|\|[0-9]+\|\|[0-9]+\|\|([0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)\|\|GET\s(/icpsrweb/ICPSR/studies\?q=([A-Za-z0-9%+*-_''"!?$.(),]*)\S*)\s+HTTP/[0-9]+[.]{1}[0-9]+\|\|(200)\|\|[0-9]+\|\|(\S*)\|\|(.+)\|\|.*$')
  homepage_p = re.compile(r'^([0-9]{8}-[0-9]{2}:[0-9]{2})\|\|[0-9]+\|\|[0-9]+\|\|([0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)\|\|GET\s(/icpsrweb/ICPSR/(series){0,1}/{0,1}[0-9]*/{0,1}studies/([0-9]+)\S*)\s+HTTP/[0-9]+[.]{1}[0-9]+\|\|(200)\|\|[0-9]+\|\|(\S*)\|\|(.+)\|\|.*$')
  download_p = re.compile(r'^([0-9]{8}-[0-9]{2}:[0-9]{2})\|\|[0-9]+\|\|[0-9]+\|\|([0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)\|\|GET\s(/cgi-bin/bob/terms2\?study=([0-9]+)\&ds=[0-9]+\&bundle=([A-Za-z0-9]+))\&path=ICPSR\s+HTTP/[0-9]+[.]{1}[0-9]+\|\|(200|302)\|\|[0-9]+\|\|(\S*)\|\|(.+)\|\|.*$')
  input_file = open(f, 'rU')
  searches = []
  homepages = []
  downloads = []
  for line in input_file:
    match = search_p.search(line)
    if match:
      searches.append(get_searches(match))
      continue
    match = homepage_p.search(line)
    if match:
      homepages.append(get_homepages(match))
      continue
    match = download_p.search(line)
    if match:
      downloads.append(get_downloads(match))
  input_file.close()
  load_search(searches)
  load_homepage(homepages)
  load_download(downloads)

def get_searches(match):
  timestamp = match.group(1)
  ip = match.group(2)
  ip_bytes = ip.split('.')
  url = match.group(3)
  referrer = match.group(6)
  browser_type = match.group(7)
  search_terms = match.group(4)
  return (timestamp, ip, int(ip_bytes[0]), int(ip_bytes[1]), int(ip_bytes[2]), int(ip_bytes[3]), url, referrer, browser_type, search_terms)

def get_homepages(match):
  timestamp = match.group(1)
  ip = match.group(2)
  ip_bytes = ip.split('.')
  url = match.group(3)
  referrer = match.group(7)
  browser_type = match.group(8)
  study = match.group(5)
  return (timestamp, ip, int(ip_bytes[0]), int(ip_bytes[1]), int(ip_bytes[2]), int(ip_bytes[3]), url, referrer, browser_type, int(study))

def get_downloads(match):
  timestamp = match.group(1)
  ip = match.group(2)
  ip_bytes = ip.split('.')
  url = match.group(3)
  referrer = match.group(7)
  browser_type = match.group(8)
  study = match.group(4)
  fmat = match.group(5)
  return (timestamp, ip, int(ip_bytes[0]), int(ip_bytes[1]), int(ip_bytes[2]), int(ip_bytes[3]), url, referrer, browser_type, int(study), fmat)

def main():
  try:
    init_database()
    for dirname, dirnames, filenames in os.walk('../weblogs'):
      for filename in filenames:
        extract(os.path.join(dirname, filename))
  except sqllite.Error, e:
    print "Error %s:" % e.args[0]
  finally:
    if CONN:
      CONN.commit()
      CONN.close()
    
if __name__ == '__main__':
  main()

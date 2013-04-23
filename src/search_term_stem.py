import os
import re
import sqlite3 as sqllite
import urllib
import nltk

CONN = sqllite.connect("../db/weblogs.db")
CONN.text_factory = str
CURSOR = CONN.cursor()

stemmer = nltk.PorterStemmer()

additions = []
for row in CURSOR.execute('SELECT id, search_terms FROM weblog_searches'):
  	search_terms_list=[]
  	for item1 in row:
  		item2 = str(item1).split('+')
    	for item3 in item2:
      		match = re.search(r'[\w\']+',item3)
      		if match:
      		   	word = stemmer.stem(match.group(0).lower())
        		search_terms_list.append(word)
  	search_terms=','.join(search_terms_list)
  	temp_list = [search_terms,int(row[0])]
  	additions.append(temp_list)
print additions

for row in additions:
	CURSOR.execute('UPDATE weblog_searches SET search_terms=? WHERE id=?',row)
CONN.commit()
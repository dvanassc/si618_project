'''
Created on Apr 3, 2013

@author: dvanassc
'''

## 1 - Load university and university ip data
execfile('load_university_ips.py')

## 2 - Load general location ip data
execfile('load_location_ips.py')

## 3 - Load studies
execfile('load_studies.py')

## 4 - Load web logs
execfile('load_weblog.py')

## 5 - Stem search terms
execfile('search_term_stem.py')
-- Counts the number of homepages accessed by university after filtering out bots
select distinct(u.name), count(*)
from weblog_homepages wh, university_ips uip, universities u
where wh.abyte = uip.abyte and wh.bbyte = uip.bbyte and wh.cbyte = uip.cbyte and wh.dbyte >= uip.dbyte1 and wh.dbyte <= uip.dbyte2 and uip.university_id = u.id and
((browser_type like 'Mozilla%' or browser_type like 'Opera%' or browser_type like 'Safari%' or browser_type like 'Nokia%' or browser_type like 'BlackBerry%') and
(browser_type not like '%Yandex%' and browser_type not like '%spider%' and browser_type not like '%Babya Discover%'
and browser_type not like '%bot%' and browser_type not like '%Daumoa%' and browser_type not like '%crawler%' and browser_type not like '%LinkCheck%'
and browser_type not like '%WebCorp%' and browser_type not like '%Yahoo! Slurp%' and browser_type not like '%Genieo%'))
group by u.name
order by count(*) desc
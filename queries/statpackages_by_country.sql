select distinct c.name,
        case
            when wl.format like '%spss%' then 'spss'
            when wl.format like '%stata%' then 'stata'
            when wl.format like '%sas%' then 'sas'
            when wl.format = 'ascii' or wl.format = 'delimited' or wl.format = 'other' then 'delimited'
            else wl.format
        end as format,
        count(*)
from weblog_downloads wl, country_ips ci, countries c
where wl.long_ip = ci.long_ip and ci.country_id = c.id and
(browser_type like 'Mozilla%' or browser_type like 'Opera%' or browser_type like 'Nokia%' or browser_type like 'BlackBerry%') and
(browser_type not like '%Yandex%' and browser_type not like '%spider%' and browser_type not like '%Babya Discover%'
and browser_type not like '%bot%' and browser_type not like '%Daumoa%' and browser_type not like '%crawler%' and browser_type not like '%LinkCheck%'
and browser_type not like '%WebCorp%' and browser_type not like '%Yahoo! Slurp%' and browser_type not like '%Genieo%')
group by c.name, format
order by c.name, count(*) desc

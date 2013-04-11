-- Queries all homepages filtering out known spiders/crawlers/bots
select * from weblog_homepages
where (browser_type like 'Mozilla%' or browser_type like 'Opera%' or browser_type like 'Safari%' or browser_type like 'Nokia%' or browser_type like 'BlackBerry%') and
(browser_type not like '%Yandex%' and browser_type not like '%spider%' and browser_type not like '%Babya Discover%'
and browser_type not like '%bot%' and browser_type not like '%Daumoa%' and browser_type not like '%crawler%' and browser_type not like '%LinkCheck%'
and browser_type not like '%WebCorp%' and browser_type not like '%Yahoo! Slurp%' and browser_type not like '%Genieo%')


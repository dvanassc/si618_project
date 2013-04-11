library(DBI)
library(RSQLite)
driver<-dbDriver("SQLite")
connect<-dbConnect(driver, dbname = "../db/weblogs.db")
log.entries = dbGetQuery(connect, "
select wl.timestamp, c.name as country, c.abbr as abbr, wl.study, wl.browser_type,
    case
        when wl.format like '%spss%' then 'spss'
        when wl.format like '%stata%' then 'stata'
        when wl.format like '%sas%' then 'sas'
        when wl.format = 'ascii' or wl.format = 'delimited' or wl.format = 'other' then 'delimited'
        else wl.format
    end as format,
    case
        when (browser_type like 'Mozilla%' or browser_type like 'Opera%' or browser_type like 'Safari%' or browser_type like 'Nokia%' or browser_type like 'BlackBerry%') and
             (browser_type not like '%Yandex%' and browser_type not like '%spider%' and browser_type not like '%Babya Discover%'
              and browser_type not like '%bot%' and browser_type not like '%Daumoa%' and browser_type not like '%crawler%' and browser_type not like '%LinkCheck%'
              and browser_type not like '%WebCorp%' and browser_type not like '%Yahoo! Slurp%' and browser_type not like '%Genieo%') then 'human'
        else 'bot'
    end as accessor
from weblog_downloads wl left outer join country_ips ci on wl.long_ip = ci.long_ip left outer join countries c on ci.country_id = c.id
")

log.entries$country <- factor(log.entries$country)
log.entries$abbr <- factor(log.entries$abbr)
log.entries$format <- factor(log.entries$format)
log.entries$accessor <- factor(log.entries$accessor)

library(ggplot2)
library(plyr)

pdf('stats_packages.pdf')
sum.stats = ddply(log.entries, c("format"), summarise, format_count = length(format))
pie(sum.stats$format_count, sum.stats$format, main = "Format Count")

sum.stats = ddply(log.entries, c("format", "country"), summarise, format_count = length(format))
for (c in levels(sum.stats$country)) {
  sum.stats.subset = subset(sum.stats, country == c)
  print(pie(sum.stats.subset$format_count, sum.stats.subset$format, main = c))
}

print(qplot(format, data = log.entries, geom = "histogram", fill = abbr))
print(qplot(format, data = log.entries, geom = "histogram", colour = abbr,
      fill = abbr, binwidth = 0.5, xlab = "Download Format", 
      main = "Histogram of Download Format by Country", alpha = I(0.7)) + 
  facet_wrap(~ abbr, nrow = 3))
dev.off()

library(DBI)
library(RSQLite)
driver<-dbDriver("SQLite")
connect<-dbConnect(driver, dbname = "../db/weblogs.db")
log.entries = dbGetQuery(connect, "
select wl.timestamp, u.name as institution, c.name as country, c.abbr as abbr, wl.study, wl.browser_type,
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
              and browser_type not like '%WebCorp%' and browser_type not like '%Yahoo! Slurp%' and browser_type not like '%Genieo%') then 'Human'
        when browser_type like '%CopperEgg%' or browser_type like '%InterMapper%' then 'ICPSR-Bot'
        else 'Bot'
    end as accessor
from weblog_downloads wl left outer join country_ips ci on wl.long_ip = ci.long_ip
                         left outer join countries c on ci.country_id = c.id
                         left outer join university_ips ui on (wl.abyte = ui.abyte and wl.bbyte = ui.bbyte and wl.cbyte = ui.cbyte and wl.dbyte >= ui.dbyte1 and wl.dbyte <= ui.dbyte2)
                         left outer join universities u on ui.university_id = u.id
")

log.entries$country <- factor(log.entries$country)
log.entries$abbr <- factor(log.entries$abbr)
log.entries$format <- factor(log.entries$format)
log.entries$accessor <- factor(log.entries$accessor)
log.entries$institution <- factor(log.entries$institution)

library(ggplot2)
library(plyr)

pdf('stats_packages_overall.pdf')

print(ggplot(log.entries, aes(format, colour = abbr, fill = abbr)) +
  geom_histogram() + ylab("Count") + xlab("Statistical Package") +
  labs(title = "Statistical Package by Country") + 
  guides(col=guide_legend(ncol=3, byrow=T)))

for (c in levels(log.entries$country)) {
  log.entries.subset = subset(log.entries, country == c)
  a.title <- paste("Preferred Statistical Packages in ", c, sep="")
  print(ggplot(log.entries.subset, aes(format, colour = format, fill = format)) +
          geom_histogram() + ylab("Count") + xlab("Statistical Package") +
          labs(title = a.title))
}

for (u in levels(log.entries$institution)) {
  log.entries.subset = subset(log.entries, institution == u)
  a.title <- paste("Preferred Statistical Packages at ", u, sep="")
  print(ggplot(log.entries.subset, aes(format, colour = format, fill = format)) +
          geom_histogram() + ylab("Count") + xlab("Statistical Package") +
          labs(title = a.title))
}

dev.off()

pdf('stats_packages_accessor.pdf')

for (a in levels(log.entries$accessor)) {
  log.entries.subset = subset(log.entries, accessor == a)
  a.title <- paste("Statistical Packages Preferred by ", a, "s", sep="")
  print(ggplot(log.entries.subset, aes(format, colour = format, fill = format)) +
          geom_histogram() + ylab("Count") + xlab("Statistical Package") +
          labs(title = a.title))
  
  for (c in levels(log.entries.subset$country)) {
    log.entries.country = subset(log.entries.subset, country == c)
    if (nrow(log.entries.country) > 0) {
      a.title <- paste("Statistical Packages Preferred by ", a, "s in ", c, sep="")
      print(ggplot(log.entries.country, aes(format, colour = format, fill = format)) +
              geom_histogram() + ylab("Count") + xlab("Statistical Package") +
              labs(title = a.title))
    }
  }
}

dev.off()

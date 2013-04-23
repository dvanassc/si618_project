library(maps)
library(DBI)
library(RSQLite)
library(ggplot2)
library(ggmap)
library(maps)
library(mapproj)
library(scales)
library(grid)
library(plyr)

driver<-dbDriver("SQLite")
connect<-dbConnect(driver, dbname = "../db/weblogs.db")

#1 - Page Requests Worldwide (Bot vs. Human)
log.entries = dbGetQuery(connect, "select cities.name, cities.lat, cities.lng, countries.name, weblog_homepages.study, weblog_homepages.browser_type,
    case
        when (weblog_homepages.browser_type like 'Mozilla%' or weblog_homepages.browser_type like 'Opera%' or weblog_homepages.browser_type like 'Safari%' or weblog_homepages.browser_type like 'Nokia%' or weblog_homepages.browser_type like 'BlackBerry%') and
             (weblog_homepages.browser_type not like '%Yandex%' and weblog_homepages.browser_type not like '%spider%' and weblog_homepages.browser_type not like '%Babya Discover%'
              and weblog_homepages.browser_type not like '%bot%' and weblog_homepages.browser_type not like '%Daumoa%' and weblog_homepages.browser_type not like '%crawler%' and weblog_homepages.browser_type not like '%LinkCheck%'
              and weblog_homepages.browser_type not like '%WebCorp%' and weblog_homepages.browser_type not like '%Yahoo! Slurp%' and weblog_homepages.browser_type not like '%Genieo%') then 'Human'
        else 'Bot'
        end as accessor
    from weblog_homepages left outer join city_ips on weblog_homepages.long_ip=city_ips.long_ip left outer join cities on city_ips.city_id=cities.id left outer join countries on cities.country_id = countries.id")
log.entries <- na.omit(log.entries)
world<-map_data('world')
sf<-data.frame(long=-83.7430378,lat=42.2808256)
pdf(file="maps_pageviews_world_botvhuman.pdf",height=15,width=20)
p<-ggplot(legend=FALSE) + geom_path(data=world,aes(x=long,y=lat,group=group),color="gray") + theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p<-p+geom_point(data=log.entries,aes(log.entries$lng,log.entries$lat,color=log.entries$accessor),size=3,alpha=I(.75)) + labs(title="Page Requests Worldwide (Bot vs. Human)") +
  guides(col=guide_legend(title=c("Accessor"),keywidth=3)) + theme(plot.title = element_text(size = 24))
p
dev.off()




#2 - Downloads Worldwide (Bot vs. Human)
log.entries2 = dbGetQuery(connect, "select cities.name, cities.lat, cities.lng, countries.name, weblog_downloads.study, weblog_downloads.browser_type,
    case
        when (weblog_downloads.browser_type like 'Mozilla%' or weblog_downloads.browser_type like 'Opera%' or weblog_downloads.browser_type like 'Safari%' or weblog_downloads.browser_type like 'Nokia%' or weblog_downloads.browser_type like 'BlackBerry%') and
             (weblog_downloads.browser_type not like '%Yandex%' and weblog_downloads.browser_type not like '%spider%' and weblog_downloads.browser_type not like '%Babya Discover%'
              and weblog_downloads.browser_type not like '%bot%' and weblog_downloads.browser_type not like '%Daumoa%' and weblog_downloads.browser_type not like '%crawler%' and weblog_downloads.browser_type not like '%LinkCheck%'
              and weblog_downloads.browser_type not like '%WebCorp%' and weblog_downloads.browser_type not like '%Yahoo! Slurp%' and weblog_downloads.browser_type not like '%Genieo%') then 'Human'
        else 'Bot'
        end as accessor
    from weblog_downloads left outer join city_ips on weblog_downloads.long_ip=city_ips.long_ip left outer join cities on city_ips.city_id=cities.id left outer join countries on cities.country_id = countries.id")

log.entries2 <- na.omit(log.entries2)
world<-map_data('world')
sf<-data.frame(long=-83.7430378,lat=42.2808256)
pdf(file="maps_downloads_world_botvhuman.pdf",height=15,width=20)
p<-ggplot(legend=FALSE) + geom_path(data=world,aes(x=long,y=lat,group=group),color="gray") +
  theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p<-p+geom_point(data=log.entries2,aes(log.entries2$lng,log.entries2$lat,color=log.entries2$accessor),size=3,alpha=I(1/2)) + labs(title="Downloads Worldwide (Bot vs. Human)") +
  guides(col=guide_legend(title=c("Accessor"),keywidth=1))
p
dev.off()




#3 - Downloads per Classification (Human Only) - Worldwide
#log.entries4
log.entries4 = dbGetQuery(connect, "select weblog_downloads.id, cities.name, cities.lat, cities.lng, classifications.code,classifications.description,classifications.study_id,weblog_downloads.study
        from weblog_downloads left outer join city_ips on weblog_downloads.long_ip = city_ips.long_ip left outer join cities on city_ips.city_id = cities.id left outer join classifications on weblog_downloads.study = classifications.study_id
        where (weblog_downloads.browser_type like 'Mozilla%' or weblog_downloads.browser_type like 'Opera%' or weblog_downloads.browser_type like 'Safari%' or weblog_downloads.browser_type like 'Nokia%' or weblog_downloads.browser_type like 'BlackBerry%') and
        (weblog_downloads.browser_type not like '%Yandex%' and weblog_downloads.browser_type not like '%spider%' and weblog_downloads.browser_type not like '%Babya Discover%'
        and weblog_downloads.browser_type not like '%bot%' and weblog_downloads.browser_type not like '%Daumoa%' and weblog_downloads.browser_type not like '%crawler%' and weblog_downloads.browser_type not like '%LinkCheck%'
        and weblog_downloads.browser_type not like '%WebCorp%' and weblog_downloads.browser_type not like '%Yahoo! Slurp%' and weblog_downloads.browser_type not like '%Genieo%')")

log.entries4 <- na.omit(log.entries4)
log.entries4$majorcode=substr(log.entries4$code,1,regexpr("([^XVI]|$)??",log.entries4$code)-1)
log.entries4$majordesc=substr(log.entries4$description,1,regexpr("(,|$)??",log.entries4$description)-1)
log.entries4$majordesc[log.entries4$majorcode=="I"]="Census Enumerations"

world<-map_data('world')
sf<-data.frame(long=-83.7430378,lat=42.2808256)

pdf(file="maps_downloads_classification_humanonly.pdf",height=15,width=20)
p<-ggplot(legend=FALSE) + geom_path(data=world,aes(x=long,y=lat,group=group),color="gray") + theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p<-p+geom_point(data=log.entries4,aes(log.entries4$lng,log.entries4$lat,color=log.entries4$majordesc),size=3,alpha=I(1/2)) + labs(title="Downloads per Classification (Human Only)") +
  guides(col=guide_legend(title=c("Classification"),keywidth=3))
p
dev.off()




#4 - Downloads per Classification (Human Only) - USA

usa.data <- subset(log.entries4,log.entries4$lat > 24.2115 & log.entries4$lat < 49.2304 & log.entries4$lng < -66.5659 & log.entries4$lng > -124.4359)
usa<-map_data('usa')
sf<-data.frame(long=-98.35,lat=39.50)

pdf(file="maps_downloads_classification_humanonly_usa.pdf",height=15,width=20)
p<-ggplot(legend=FALSE) + geom_path(data=usa,aes(x=long,y=lat,group=group),color="gray") + theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p<-p+geom_point(data=usa.data,aes(usa.data$lng,usa.data$lat,color=usa.data$majordesc,shape=usa.data$accessor),size=6,alpha=I(1/2)) + labs(title="Downloads per Classification (Human Only) - USA") +
  guides(col=guide_legend(title=c("Classification"),keywidth=3))
p
dev.off()




#5 - Page Requests per Classification (Human Only, World)
log.entries5 = dbGetQuery(connect, "select weblog_homepages.id, cities.name, cities.lat, cities.lng, classifications.code,classifications.description,classifications.study_id,weblog_homepages.study
        from weblog_homepages left outer join city_ips on weblog_homepages.long_ip = city_ips.long_ip left outer join cities on city_ips.city_id = cities.id left outer join classifications on weblog_homepages.study = classifications.study_id
        where (weblog_homepages.browser_type like 'Mozilla%' or weblog_homepages.browser_type like 'Opera%' or weblog_homepages.browser_type like 'Safari%' or weblog_homepages.browser_type like 'Nokia%' or weblog_homepages.browser_type like 'BlackBerry%') and
        (weblog_homepages.browser_type not like '%Yandex%' and weblog_homepages.browser_type not like '%spider%' and weblog_homepages.browser_type not like '%Babya Discover%'
        and weblog_homepages.browser_type not like '%bot%' and weblog_homepages.browser_type not like '%Daumoa%' and weblog_homepages.browser_type not like '%crawler%' and weblog_homepages.browser_type not like '%LinkCheck%'
        and weblog_homepages.browser_type not like '%WebCorp%' and weblog_homepages.browser_type not like '%Yahoo! Slurp%' and weblog_homepages.browser_type not like '%Genieo%')")

log.entries5 <- na.omit(log.entries5)
log.entries5$majorcode=substr(log.entries5$code,1,regexpr("([^XVI]|$)??",log.entries5$code)-1)
log.entries5$majordesc=substr(log.entries5$description,1,regexpr("(,|$)??",log.entries5$description)-1)
log.entries5$majordesc[log.entries5$majorcode=="I"]="Census Enumerations"

world<-map_data('world')
sf<-data.frame(long=-83.7430378,lat=42.2808256)
pdf(file="maps_pageviews_classification_humanonly.pdf",height=15,width=20)
p<-ggplot(legend=FALSE) + geom_path(data=world,aes(x=long,y=lat,group=group),color="gray") + theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p<-p+geom_point(data=log.entries5,aes(log.entries5$lng,log.entries5$lat,color=log.entries5$majordesc),size=2,alpha=I(1/2)) + labs(title="Page Requests per Classification (Human Only)") +
  guides(col=guide_legend(title=c("Classification"),keywidth=3))
p
dev.off()




#6 - Pageviews per Classification (Human Only) - USA
usa.data <- subset(log.entries5,log.entries5$lat > 24.2115 & log.entries5$lat < 49.2304 & log.entries5$lng < -66.5659 & log.entries5$lng > -124.4359)
usa<-map_data('usa')
sf<-data.frame(long=-98.35,lat=39.50)

pdf(file="maps_pageviews_classification_humanonly_usa.pdf",height=15,width=20)
p<-ggplot(legend=FALSE) + geom_path(data=usa,aes(x=long,y=lat,group=group),color="gray") + theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p<-p+geom_point(data=usa.data,aes(usa.data$lng,usa.data$lat,color=usa.data$majordesc),size=6,alpha=I(1/2)) + labs(title="Pageviews per Classification (Human Only) - USA") +
  guides(col=guide_legend(title=c("Classification"),keywidth=3))
p
dev.off()




#7 - Page Request Concentrations - World (Humans Only)
log.entries6 = dbGetQuery(connect, "select cities.name, cities.lat, cities.lng, countries.name, weblog_homepages.study, weblog_homepages.browser_type
    from weblog_homepages left outer join city_ips on weblog_homepages.long_ip=city_ips.long_ip left outer join cities on city_ips.city_id=cities.id left outer join countries on cities.country_id = countries.id
    where (weblog_homepages.browser_type like 'Mozilla%' or weblog_homepages.browser_type like 'Opera%' or weblog_homepages.browser_type like 'Safari%' or weblog_homepages.browser_type like 'Nokia%' or weblog_homepages.browser_type like 'BlackBerry%') and
         (weblog_homepages.browser_type not like '%Yandex%' and weblog_homepages.browser_type not like '%spider%' and weblog_homepages.browser_type not like '%Babya Discover%'
          and weblog_homepages.browser_type not like '%bot%' and weblog_homepages.browser_type not like '%Daumoa%' and weblog_homepages.browser_type not like '%crawler%' and weblog_homepages.browser_type not like '%LinkCheck%'
          and weblog_homepages.browser_type not like '%WebCorp%' and weblog_homepages.browser_type not like '%Yahoo! Slurp%' and weblog_homepages.browser_type not like '%Genieo%')")
log.entries6<-na.omit(log.entries6)
log6.df <- data.frame(log.entries6)
log6.df<-ddply(log6.df,c("name.1"),summarise,count = length(name))

world<-map_data('world')
world$region<-toupper(world$region)

#Update the Country Names to Match the Spelling/Format of the Geographic Data
log6.df$name.1[log6.df$name.1 == 'VIET NAM'] <- 'VIETNAM'
log6.df$name.1[log6.df$name.1 == 'THE FORMER YUGOSLAV REPUBLIC OF MACEDONIA'] <- 'MACEDONIA'
log6.df$name.1[log6.df$name.1 == 'REPUBLIC OF MOLDOVA'] <- 'MOLDOVA'
log6.df$name.1[log6.df$name.1 == 'BRUNEI DARUSSALAM'] <- 'BRUNEI'
log6.df$name.1[log6.df$name.1 == 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC'] <- 'LAOS'
log6.df$name.1[log6.df$name.1 == 'RUSSIAN FEDERATION'] <- 'USSR'
log6.df$name.1[log6.df$name.1 == 'REPUBLIC OF KOREA'] <- 'SOUTH KOREA'
log6.df$name.1[log6.df$name.1 == 'ISLAMIC REPUBLIC OF IRAN'] <- 'IRAN'
log6.df$name.1[log6.df$name.1 == 'UNITED KINGDOM'] <- 'UK'
log6.df$name.1[log6.df$name.1 == 'UNITED STATES'] <- 'USA'

world$count <- log6.df$count[match(world$region,log6.df$name.1)]

sf<-data.frame(long=-83.7430378,lat=42.2808256)

pdf(file="maps_pageviews_humanonly_shading.pdf",height=15,width=20)
p<-ggplot() + geom_polygon(data=world,aes(x=long,y=lat,group=group,fill=world$count)) +
  labs(title="Page Request Concentrations - World (Humans Only)") + guides(col=guide_legend(title=c("Pageviews"),keywidth=3)) +
  theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p
dev.off()




#8 - Page Request Concentrations - World (Humans Only, No USA)
log.entries6<-na.omit(log.entries6)
log6.df <- data.frame(log.entries6)
log6.df<-ddply(log6.df,c("name.1"),summarise,count = length(name))
log6.df<-subset(log6.df,log6.df$name.1 != 'USA')


world<-map_data('world')
world$region<-toupper(world$region)

#Update the Country Names to Match the Spelling/Format of the Geographic Data
log6.df$name.1[log6.df$name.1 == 'VIET NAM'] <- 'VIETNAM'
log6.df$name.1[log6.df$name.1 == 'THE FORMER YUGOSLAV REPUBLIC OF MACEDONIA'] <- 'MACEDONIA'
log6.df$name.1[log6.df$name.1 == 'REPUBLIC OF MOLDOVA'] <- 'MOLDOVA'
log6.df$name.1[log6.df$name.1 == 'BRUNEI DARUSSALAM'] <- 'BRUNEI'
log6.df$name.1[log6.df$name.1 == 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC'] <- 'LAOS'
log6.df$name.1[log6.df$name.1 == 'RUSSIAN FEDERATION'] <- 'USSR'
log6.df$name.1[log6.df$name.1 == 'REPUBLIC OF KOREA'] <- 'SOUTH KOREA'
log6.df$name.1[log6.df$name.1 == 'ISLAMIC REPUBLIC OF IRAN'] <- 'IRAN'
log6.df$name.1[log6.df$name.1 == 'UNITED KINGDOM'] <- 'UK'

world$count <- log6.df$count[match(world$region,log6.df$name.1)]

sf<-data.frame(long=-83.7430378,lat=42.2808256)

pdf(file="maps_pageviews_humanonly_shading_nousa.pdf",height=15,width=20)
p<-ggplot() + geom_polygon(data=world,aes(x=long,y=lat,group=group,fill=world$count)) +
  labs(title="Page Request Concentrations - World (Humans Only, No USA)") + guides(col=guide_legend(title=c("Pageviews"),keywidth=3)) +
  theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p
dev.off()

#9 - Download Concentrations - World (Humans Only)
log.entries7 = dbGetQuery(connect, "select cities.name, cities.lat, cities.lng, countries.name, weblog_downloads.study, weblog_downloads.browser_type
    from weblog_downloads left outer join city_ips on weblog_downloads.long_ip=city_ips.long_ip left outer join cities on city_ips.city_id=cities.id left outer join countries on cities.country_id = countries.id
    where (weblog_downloads.browser_type like 'Mozilla%' or weblog_downloads.browser_type like 'Opera%' or weblog_downloads.browser_type like 'Safari%' or weblog_downloads.browser_type like 'Nokia%' or weblog_downloads.browser_type like 'BlackBerry%') and
         (weblog_downloads.browser_type not like '%Yandex%' and weblog_downloads.browser_type not like '%spider%' and weblog_downloads.browser_type not like '%Babya Discover%'
          and weblog_downloads.browser_type not like '%bot%' and weblog_downloads.browser_type not like '%Daumoa%' and weblog_downloads.browser_type not like '%crawler%' and weblog_downloads.browser_type not like '%LinkCheck%'
          and weblog_downloads.browser_type not like '%WebCorp%' and weblog_downloads.browser_type not like '%Yahoo! Slurp%' and weblog_downloads.browser_type not like '%Genieo%')")
log.entries7<-na.omit(log.entries7)
log7.df <- data.frame(log.entries7)
log7.df<-ddply(log7.df,c("name.1"),summarise,count = length(name))

world<-map_data('world')
world$region<-toupper(world$region)

#Update the Country Names to Match the Spelling/Format of the Geographic Data
log7.df$name.1[log7.df$name.1 == 'VIET NAM'] <- 'VIETNAM'
log7.df$name.1[log7.df$name.1 == 'THE FORMER YUGOSLAV REPUBLIC OF MACEDONIA'] <- 'MACEDONIA'
log7.df$name.1[log7.df$name.1 == 'REPUBLIC OF MOLDOVA'] <- 'MOLDOVA'
log7.df$name.1[log7.df$name.1 == 'BRUNEI DARUSSALAM'] <- 'BRUNEI'
log7.df$name.1[log7.df$name.1 == 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC'] <- 'LAOS'
log7.df$name.1[log7.df$name.1 == 'RUSSIAN FEDERATION'] <- 'USSR'
log7.df$name.1[log7.df$name.1 == 'REPUBLIC OF KOREA'] <- 'SOUTH KOREA'
log7.df$name.1[log7.df$name.1 == 'ISLAMIC REPUBLIC OF IRAN'] <- 'IRAN'
log7.df$name.1[log7.df$name.1 == 'UNITED KINGDOM'] <- 'UK'
log7.df$name.1[log7.df$name.1 == 'UNITED STATES'] <- 'USA'

world$count <- log7.df$count[match(world$region,log7.df$name.1)]

sf<-data.frame(long=-83.7430378,lat=42.2808256)

pdf(file="maps_downloads_humanonly_shading.pdf",height=15,width=20)
p<-ggplot() + geom_polygon(data=world,aes(x=long,y=lat,group=group,fill=world$count)) +
  labs(title="Download Concentrations - World (Humans Only)") + guides(col=guide_legend(title=c("Downloads"),keywidth=3)) +
  theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p
dev.off()



#10 - Download Concentrations - World (Humans Only, No USA)
log.entries7<-na.omit(log.entries7)
log7.df <- data.frame(log.entries7)
log7.df<-ddply(log7.df,c("name.1"),summarise,count = length(name))
log7.df<-subset(log7.df,log7.df$name.1 != 'USA')


world<-map_data('world')
world$region<-toupper(world$region)

#Update the Country Names to Match the Spelling/Format of the Geographic Data
log7.df$name.1[log7.df$name.1 == 'VIET NAM'] <- 'VIETNAM'
log7.df$name.1[log7.df$name.1 == 'THE FORMER YUGOSLAV REPUBLIC OF MACEDONIA'] <- 'MACEDONIA'
log7.df$name.1[log7.df$name.1 == 'REPUBLIC OF MOLDOVA'] <- 'MOLDOVA'
log7.df$name.1[log7.df$name.1 == 'BRUNEI DARUSSALAM'] <- 'BRUNEI'
log7.df$name.1[log7.df$name.1 == 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC'] <- 'LAOS'
log7.df$name.1[log7.df$name.1 == 'RUSSIAN FEDERATION'] <- 'USSR'
log7.df$name.1[log7.df$name.1 == 'REPUBLIC OF KOREA'] <- 'SOUTH KOREA'
log7.df$name.1[log7.df$name.1 == 'ISLAMIC REPUBLIC OF IRAN'] <- 'IRAN'
log7.df$name.1[log7.df$name.1 == 'UNITED KINGDOM'] <- 'UK'

world$count <- log7.df$count[match(world$region,log7.df$name.1)]

sf<-data.frame(long=-83.7430378,lat=42.2808256)

pdf(file="maps_downloads_humanonly_shading_nousa.pdf",height=15,width=20)
p<-ggplot() + geom_polygon(data=world,aes(x=long,y=lat,group=group,fill=world$count)) +
  labs(title="Download Concentrations - World (Humans Only, No USA)") + guides(col=guide_legend(title=c("Downloads"),keywidth=3)) +
  theme(panel.background = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.text.x = element_blank(),axis.text.y = element_blank()) +
  theme(axis.ticks = element_blank()) +
  xlab("") + ylab("")
p
dev.off()
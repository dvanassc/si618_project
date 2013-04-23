library(DBI)
library(RSQLite)
library(stringr)
library(plyr)
library(gplots)
library(tm)
library(wordcloud)
library(prettyR)

driver<-dbDriver("SQLite")
connect<-dbConnect(driver, dbname = "../db/weblogs.db")
log.searches = dbGetQuery(connect, "SELECT ws.search_terms AS searches,
                          c.name AS country
                          FROM weblog_searches ws 
                          LEFT OUTER JOIN country_ips ci on ws.long_ip = ci.long_ip
                          LEFT OUTER JOIN countries c on ci.country_id = c.id
                          WHERE ws.browser_type NOT LIKE '%CopperEgg%'
                          AND ws.browser_type NOT LIKE '%InterMapper%'
                          AND ws.browser_type NOT LIKE '%Yandex%'
                          AND ws.browser_type NOT LIKE '%spider%'
                          AND ws.browser_type NOT LIKE '%Babya Discover%'
                          AND ws.browser_type NOT LIKE '%bot%'
                          AND ws.browser_type NOT LIKE '%Daumoa%'
                          AND ws.browser_type NOT LIKE '%crawler%'
                          AND ws.browser_type NOT LIKE '%LinkCheck%'
                          AND ws.browser_type NOT LIKE '%WebCorp%'
                          AND ws.browser_type NOT LIKE '%Yahoo! Slurp%'
                          AND ws.browser_type NOT LIKE '%Genieo%'")
log.searches$searches <- as.vector(strsplit(log.searches$searches,","))
log.searches$country <- as.factor(log.searches$country)
search.corpus <- Corpus(VectorSource(log.searches$searches))
search.corpus <- tm_map(search.corpus, removeWords, stopwords('english'))

#Wordcloud
pdf(file="wordcloud.pdf",height=8,width=8)
p<-wordcloud(search.corpus, colors=brewer.pal(6,"Dark2"),random.order=F,max.words=100)
p
dev.off()
search.tdm <- TermDocumentMatrix(search.corpus)
search.tdmcluster <- removeSparseTerms(search.tdm,sparse=.994)
search.df <- as.data.frame(inspect(search.tdmcluster),stringAsFactors=F)
search.dfscale <- scale(search.df)
search.clusters <- hclust(dist(search.dfscale, method="euclidean"))
#Dendro World
pdf(file="dendrogramworld.pdf",height=15,width=20)
p <- plot(search.clusters) +
  rect.hclust(search.clusters, k=9, border='red')
p
dev.off()

#Dendro Korea
searchKorea <- subset(log.searches, log.searches$country == 'REPUBLIC OF KOREA')
search.corpus <- Corpus(VectorSource(searchKorea$searches))
search.corpusK <- tm_map(search.corpus, removeWords, stopwords('english'))
search.tdm <- TermDocumentMatrix(search.corpusK)
search.tdmcluster <- removeSparseTerms(search.tdm,sparse=.995)
search.df <- as.data.frame(inspect(search.tdmcluster),stringAsFactors=F)
search.dfscale <- scale(search.df)
search.clusters <- hclust(dist(search.dfscale, method="euclidean"))
pdf(file="dendrogramkorea.pdf",height=15,width=20)
p <- plot(search.clusters) +
  rect.hclust(search.clusters, k=9, border='red')
p
dev.off()

#Dendro US
searchUS <- subset(log.searches, log.searches$country == 'UNITED STATES')
search.corpus <- Corpus(VectorSource(searchUS$searches))
search.corpusU <- tm_map(search.corpus, removeWords, stopwords('english'))
search.tdm <- TermDocumentMatrix(search.corpusU)
search.tdmcluster <- removeSparseTerms(search.tdm,sparse=.991)
search.df <- as.data.frame(inspect(search.tdmcluster),stringAsFactors=F)
search.dfscale <- scale(search.df)
search.clusters <- hclust(dist(search.dfscale, method="euclidean"))
pdf(file="dendrogramus.pdf",height=15,width=20)
p <- plot(search.clusters) +
  rect.hclust(search.clusters, k=9, border='red')
p
dev.off()

#Dendro China
searchChina <- subset(log.searches, log.searches$country == 'CHINA')
search.corpus <- Corpus(VectorSource(searchChina$searches))
search.corpusC <- tm_map(search.corpus, removeWords, stopwords('english'))
search.tdm <- TermDocumentMatrix(search.corpusC)
search.tdmcluster <- removeSparseTerms(search.tdm,sparse=.992)
search.df <- as.data.frame(inspect(search.tdmcluster),stringAsFactors=F)
search.dfscale <- scale(search.df)
search.clusters <- hclust(dist(search.dfscale, method="euclidean"))
pdf(file="dendrogramchina.pdf",height=15,width=20)
p <- plot(search.clusters) +
  rect.hclust(search.clusters, k=9, border='red')
p
dev.off()
#聯合知識庫社會運動相關新聞爬蟲

library("xml2")
library("httr")

allhrefs <- c()
url <- 'http://udndata.com/ndapp/Searchdec2007?udndbid=udndata&page=1&SearchString=%A6%50%A9%CA%B1%42%AB%C3%2B%A4%E9%B4%C1%3E%3D20100101%2B%A4%E9%B4%C1%3C%3D20161210%2B%B3%F8%A7%4F%3D%C1%70%A6%58%B3%F8%7C%B8%67%C0%D9%A4%E9%B3%F8%7C%C1%70%A6%58%B1%DF%B3%F8%7CUpaper&sharepage=10&select=1&kind=2'
url <- GET(url, set_cookies('JSESSIONID'='28525866F2BBC76F6F64B060288B5329-n1'))
doc <- read_html(url)
#注意：聯合報每一則新聞的url的pattern為'//*[@align="left"]/a' 
#要從最原始的程式碼去檢查，看規律
lastpage <- xml_find_all(doc, '//*[@align="center"]//a')
lastpageurl <- xml_attr(lastpage, "href")
lastpageurl <- lastpageurl[22]
lastpageurl <- gsub("sharepage=10",replacement = " ",lastpageurl)
lastpage.num <- as.numeric(sub(".*page=([0-9]+).*", "\\1", lastpageurl))

for (i in c(1:lastpage.num)) {
url <- paste0('http://udndata.com/ndapp/Searchdec2007?udndbid=udndata&page=' ,i, '&SearchString=%A6%50%A9%CA%B1%42%AB%C3%2B%A4%E9%B4%C1%3E%3D20100101%2B%A4%E9%B4%C1%3C%3D20161210%2B%B3%F8%A7%4F%3D%C1%70%A6%58%B3%F8%7C%B8%67%C0%D9%A4%E9%B3%F8%7C%C1%70%A6%58%B1%DF%B3%F8%7CUpaper&sharepage=10&select=1&kind=2')
url <- GET(url, set_cookies('JSESSIONID'='28525866F2BBC76F6F64B060288B5329-n1'))
doc <- read_html(url)
findall <- xml_find_all(doc, '//*[@align="left"]/a')
findall <- findall[-c(1:3)] #刪掉我不想要的url，廢物url
findall <- findall[-length(findall)]
findall
href <- xml_attr(findall, "href")
href <- href[!is.na(href)] #處理龐雜的url
href <-href[-length(href)] #處理龐雜的url
hrefs <- paste0('http://udndata.com', href)
allhrefs <- c(allhrefs,hrefs)
print(length(allhrefs))
}


alldata <- data.frame(title = character(0), 
   content = character(0),
   time = character(0),
   author = character(0),
   link = character(0))
for (allhref in allhrefs){
   aurl <- GET(allhref, set_cookies('JSESSIONID'= '28525866F2BBC76F6F64B060288B5329-n1'))
   tdoc <- read_html(aurl)
   link <- allhref
   
   title <- xml_text(xml_find_all(tdoc, '//*[@class="story_title"]'))
   title <- title[2] #注意，要找第二個title
   
   content <- xml_text(xml_find_all(tdoc,  contentxpath <- '//*[@align="left"]/table[3]/tr/td//p'))
   temp <- content
   content <- paste(content, collapse = " ")
   
   time <- temp[length(xml_find_all(tdoc,  contentxpath <- '//*[@align="left"]/table[3]/tr/td//p')) - 1]
   time <- substr(time, 2, 11)
   
   
   author <- xml_text(xml_find_all(tdoc, '//*[@class="story_author"]'))
   author <- gsub("【", "", author)
   author <- gsub("】", "", author)
   author <- sub("記者(.{3})╱.{2}報導","\\1", author)
   
   tempdf <- data.frame(title = title, content = content, time = time,  author = author, link = link)
   alldata <- rbind(alldata, tempdf)
   print(nrow(alldata))
}
save(alldata_udn,file='udn.RData')


View(alldata_udn)


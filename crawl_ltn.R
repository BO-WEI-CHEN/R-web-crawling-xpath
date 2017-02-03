#crawling的第一件事就是觀察網頁的hyperlink
#再來就是選擇你想要的資料區間，點開檢查觀察html，複製xpath

################################################################################
library(xml2) #xml2可以讓你直接取得某個網頁的網址
url <- 'http://news.ltn.com.tw/search?keyword=食安&conditions=and&SYear=2016&SMonth=9&SDay=4&EYear=2016&EMonth=11&EDay=4'

#xpath



doc   <- read_html(url)
doc

#目標：取出我想要的新聞的超連結

hrefpath <- '//*[@id="newslistul"]//li/a'
hrefpath
#//newslistul下全部的新聞我都要

findall <- xml_find_all(doc, hrefpath)
findall

#href <- xml_attr(xml_find_all(doc,'//*[@id="newslistul"]//li/a'),"href")
href <- xml_attr(findall,"href")
#如果你只使用xml_text只會取到新聞標題
#但是xml_attr可以取得 findall中，a href=""內的屬性的資料，並指定給herf
href




hrefs <- paste0('http://news.ltn.com.tw', href)
#paste是在做補“完整網址”的動作

hrefs
#顯示出全部的新聞的網址（第一個大頁面下的新聞的網址）


#以抓第一個大頁面下的第二篇新聞為例，如果把[2]改成[i]（寫成一個loop）就可以把15篇全部抓下來
alldata <- data.frame(title=character(0),
                      content=character(0),
                      timestamp=character(0),
                      journalist=character(0),
                      link=character(0)
                      )
alldata

for(i in c(1:length(hrefs))){
tdoc <- read_html(hrefs[i]) 
# "http://news.ltn.com.tw/news/life/breakingnews/1875985"
   
#titlexpath <- '//*[@id="main"]//h1'
#findtitle <- xml_find_all(tdoc, titlexpath)
#title <- xml_text(findtitle)
   
#取得新聞的標題
title <- trimws(xml_text(xml_find_first(tdoc, '//*[@id="main"]//h1')))
#再來取得內文，可以發現內文有多段
#怎麼發現？點開新聞，將游標移至內文，點開檢查，會發現很多<p>...</p>，
#點進去第一個<p>...</p>，copy xpath，會取得以下超連結 //*[@id="newstext"]/p[1]，
#會發現這是第一個段落的超連結，所以將p[1]，改成 //p就會取得內文全部的段落。
#contentxpath <- '//*[@id="newstext"]//p'
#findcontent <- xml_find_all(tdoc, contentxpath)
#content <- xml_text(findcontent)
   
content <- trimws(xml_text(xml_find_all(tdoc, '//*[@id="newstext"]//p')))
content <- paste(content, collapse = " ")
#把段落砍掉，變成一篇完整的文章

#取得新聞時間
timestamp <- trimws(xml_text(xml_find_all(tdoc, '//*[@id="newstext"]//span')))
   
########2016_11_11會教########
journalist <-  sub(".*記者(.+)[／攝].*", "\\1", content)
tempdf <- data.frame(title=title, content=content, journalist=journalist, timestamp=timestamp, link=hrefs[i])
alldata <- rbind(alldata, tempdf)
}

View(alldata)


#存成其他檔案
write.csv(tempdf, "text.csv", row.names=F, fileEncoding = "UTF-8")
save(tempdf, file="test.RData")

lastpage.path <- '//*[@id="page"]/a[@class="p_last"]'
lastpage.url <- xml_attr(xml_find_first(doc, lastpage.path), "href")
lastpage.url
lastpage.num <-
  as.numeric(sub(".*page=([0-9]+).*", "\\1", lastpage.url))
lastpage.num








#自由時報社會運動相關新聞爬蟲

# Crawling ltn
library(xml2)
len<- length  #只是函式轉換，方便
options(stringsAsFactors = F) # creating data.frame
#df <- data.frame(a,b,c, stringsAsFactors = F)
pre <- 'http://news.ltn.com.tw'
# Get the initial index page url -------------------------------------------------
q <- "抗議" #新聞關鍵字：抗議
i <- 1
url <-
   paste0('http://news.ltn.com.tw/search?page=', i,
      '&keyword=', q,
      '&conditions=and&SYear=2015&SMonth=1&SDay=1&EYear=2015&EMonth=3&EDay=31'
   )
url

# Get all article links ---------------------------------------------------
monthvec <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
#每個月抓一次的語法
#每一個月有幾天

# Defining function to retrieve page data ---------------------------------

doc2df <- function(doc){
   href <- xml_attr(xml_find_all(doc, '//*[@id="newslistul"]//li/a'), "href")
   content <- xml_text(xml_find_all(doc, '//*[@id="newstext"]/p'))
   content <- paste(content, collapse = " ")
   
#for(i in c(1:length(hrefpath1))){
 #  doc   <- read_html(url)
 #  hrefpath <- xml_attr(href,"href")
 #  hrefpath1 <- paste0('http://news.ltn.com.tw', hrefpath)
 #  tdoc <- read_html(hrefpath1[i])
 #  content <- trimws(xml_text(xml_find_all(tdoc, '//*[@id="newstext"]//p')))
 #  content <- paste(content, collapse = " ")
#}
   
   #//*[@id="newstext"]/p[1] 自由時報新聞段落的xpath
   #但是content抓不下來 為什麼？覺得困惑？2016/11/24 救命！
   category <- xml_attr(xml_find_all(doc, '//*[@id="newslistul"]//li/img'), "src")
   category <- as.numeric(sub(".*tab([0-9]+).*", "\\1", category))
   
   title <- xml_text(xml_find_all(doc, '//*[@id="newslistul"]//li/a'))
   timestamp <- xml_text(xml_find_all(doc, '//*[@id="newslistul"]//li/span'))
   href <- paste0(pre, href)
   
   #以下在做錯誤偵測
   tryCatch({tempdf <- data.frame(href, content, category, title, timestamp)}, 
      error = function(err){
         #tempdf <- data.frame(href=character(0), content=character(0), category=character(0), title=character(0), timestamp=character(0))
         #print()
      })
   
   return(tempdf)
}


# Query by different duration ---------------------------------------------

urls <- c()
#先創造一個空集合
#把for的結果塞進去

for (y in c(2015:2015)) {
   for (m in c(1:3)) {
      url <-
         #將hyper link拆掉
         paste0(
            'http://news.ltn.com.tw/search?keyword=', q,
            '&conditions=and&SYear=', y,
            '&SMonth=', m,
            '&SDay=1&EYear=', y,
            '&EMonth=', m,
            '&EDay=', monthvec[m]
         )
      urls <- c(urls, url) #把url的結果，塞給新的vector:urls
   }
}


# Create an empty data frame to store data --------------------------------

result <- data.frame(
   timestamp = character(0),
   href = character(0),
   title = character(0),
   category = character(0),
   content = character(0),
   stringsAsFactors = F
)
#always remember to add: stringAsFactors = F

# Crawl by urls -----------------------------------------------------------

for(url in urls){
   print(url)
   doc   <- read_html(url)
   lastpage.path <- '//*[@id="page"]/a[@class="p_last"]'
   
   #自由時報最後一頁的xpath規則
   #//*[@id="page"]/a[4]
   #a[@class="p_last"]
   
   lastpage.url <- xml_attr(xml_find_first(doc, lastpage.path), "href")
   if (is.na(lastpage.url)) {
      tempdf <- doc2df(doc)
      result <- rbind(result, tempdf)
      next
      #Notice : next :如果發生這個情形我下面的語法就不執行了
      
   }
   lastpage.num <- as.numeric(sub(".*page=([0-9]+).*", "\\1", lastpage.url))
   for (page in c(1:lastpage.num)) {
      pageurl <- sprintf(sub("keyword","page=%d&keyword", url), page)
      doc   <- read_html(pageurl)
      tempdf <- doc2df(doc)
      result <- rbind(result, tempdf)
   }
   print(nrow(result))
}

View(result)

#將最後的result輸出成CSV檔案，其中sep（分割）的依據為","（逗號分隔檔案）
#write.table(result, file="result.csv", sep=",")
#result
################################################################################
################################################################################


# Remove duplicated row ---------------------------------------------------
#result <- result[!duplicated(result), ]
#apply(result, 2, class)
#class(result$content)



# Save to RData -----------------------------------------------------------
#save(result, file = "ltn_index2.RData")
#load('ltn_index2.RData')
#apply(result, 2, class)
#class(result$content)

################################################################################
################################################################################
#tdf$area <- gsub("\\s", NA, tdf$area)
#result$timestamp <- gsub("\\s", "", result$timestamp)


#allhref


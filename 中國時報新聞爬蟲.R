
doc2df <- function(doc){
  date <- trimws(xml_text(xml_find_first(doc, '//*[@id="ONEAD-mobile-origin-content"]/div/article/div[2]/div[1]/time')))
  title <- trimws(xml_text(xml_find_first(doc, '//*[@id="ONEAD-mobile-origin-content"]/div/article/header/h1')))
  content <- trimws(xml_text(xml_find_all(doc, '//*[@id="ONEAD-mobile-origin-content"]/div/article/article//p')))
  content <- paste(content, collapse = " ")
  journalist <- trimws(xml_text(xml_find_all(doc, '//*[@id="ONEAD-mobile-origin-content"]/div/article/div[2]/div[1]/div')))
  tryCatch({tempdf <- data.frame(date, title, content, journalist)}, 
           error = function(err){
             tempdf <- data.frame(date=character(0), title=character(0), content=character(0), journalist=character(0))
             # print()
           })
  
  return(tempdf)  
}
url <-'https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&rsz=12&num=12&hl=zh_TW&prettyPrint=false&source=gcsc&gss=.com&sig=0c3990ce7a056ed50667fe0c3873c9b6&cx=013510920051559618976:klsxyhsnf7g&q=%E5%90%8C%E6%80%A7%E5%A9%9A%E5%A7%BB&lr=&filter=1&sort=&googlehost=www.google.com&callback=google.search.Search.apiary16457&nocache=1481187616172'
text <- content(GET(url), 'text')
text <- substr(text, 50, nchar(text)-1)
text <- gsub(")",replacement=" ",text)
data <- fromJSON(text)
hrefs <- data$results$url
textdf <- 
  data.frame(
    title2 = character(0),
    content2 = character(0),
    date = character(0),
    journalist = character(0)
  )

for(href in hrefs){
  doc   <- read_html(href)
  tempdf <- doc2df(doc)
  textdf <- rbind(textdf, tempdf)
}


num <- c(12,23,34,45,56,67,78)

allhrefs <- c()
for (i in c(1:length(num))) 
{
num1 <- num[i]
curl <- paste0('https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&rsz=12&num=12&hl=zh_TW&prettyPrint=false&source=gcsc&gss=.com&sig=0c3990ce7a056ed50667fe0c3873c9b6&start=' ,num1, '&cx=013510920051559618976:klsxyhsnf7g&q=%E5%90%8C%E6%80%A7%E5%A9%9A%E5%A7%BB&lr=&filter=1&sort=&googlehost=www.google.com&callback=google.search.Search.apiary16762&nocache=1481198203835')
text <- content(GET(curl), 'text')
text <- substr(text, 50, nchar(text)-1)
text <- gsub(")",replacement=" ",text)
data <- fromJSON(text)
hrefs <- data$results$url
allhrefs <- c(allhrefs, hrefs)
}

for(allhref in allhrefs){
  doc  <- read_html(allhref)
  tempdf <- doc2df(doc)
  textdf <- rbind(textdf, tempdf)
}
textdf <- textdf[!duplicated(textdf), ]



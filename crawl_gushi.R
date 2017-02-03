#故事 寫給所有人的歷史
#日本
url_story <- 'http://gushi.tw/?s=%E6%97%A5%E6%9C%AC'
doc_story <- read_html(url_story)

href_story <- xml_find_all(doc_story, '//*[@class="search_result_list"]//li/a')
hrefs_story <- xml_attr(xml_find_all(doc_story, '//*[@id="index-969970"]/div/div//div/div[2]/div/div/h3/a'), 'href')
#//*[@id="index-969970"]/div/div//div/div[2]/div/div/h3/a

a <- c(1,2,3,4)
a <- a[-c(4)]
View(a)
View(a)
#//*[@id="post-38820"]//h1
#//*[@id="post-38820"]//p
#//*[@class="date-info"]
#//*[@id="post-38820"]//div[3]/a

tdoc <- read_html(hrefs_story[1]) 
title <- trimws(xml_text(xml_find_first(tdoc, '//*[@id="post-38820"]//h1')))
content <- trimws(xml_text(xml_find_all(tdoc, '//*//*[@id="post-38820"]//p')))
content <- paste(content, collapse = " ")
writer <- trimws(xml_text(xml_find_all(tdoc, '//*[@id="post-38820"]//div[3]/a')))
timestamp <- trimws(xml_text(xml_find_all(tdoc, '//*[@class="date-info"]')))

alldata_story <- data.frame(title=character(0),
                          content=character(0),
                          writer=character(0),
                          timestamp=character(0),
                          link=character(0)
)

for (i in c(1:length(hrefs_story))){
  tdoc <- read_html(hrefs_story[i]) 
  title <- trimws(xml_text(xml_find_first(tdoc, '//*[@id="post-38820"]//h1')))
  content <- trimws(xml_text(xml_find_all(tdoc, '//*//*[@id="post-38820"]//p')))
  content <- paste(content, collapse = " ")
  writer <- trimws(xml_text(xml_find_all(tdoc, '//*[@id="post-38820"]//div[3]/a')))
  timestamp <- trimws(xml_text(xml_find_all(tdoc, '//*[@class="date-info"]')))
  tempdf_story <- data.frame(title=title, content=content, writer=writer, timestamp=timestamp, link=hrefs_story[i])
  alldata_story <- rbind(alldata_story, tempdf_story)
}

save(alldata_story, file="gushi.RData")


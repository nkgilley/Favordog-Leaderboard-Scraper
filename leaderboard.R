# Favordog Leaderboard Scraper
# Install RSelenium if required. You will need phantomjs in your path or follow instructions
# in package vignettes
# devtools::install_github("ropensci/RSelenium")
# login first
username <- 'user'
password <- 'password123'
leaderboardURL <- 'http://favordog.com/Selection/LeaderBoard.aspx?ID=BBCMPC1034'
outputfile <- "D:/Nolan/Google Drive/favordog-leaderboard.csv"

library(RSelenium)
pJS <- phantom() # start phantomjs
remDr <- remoteDriver(browserName = "phantomjs")
remDr$open()
remDr$navigate("http://favordog.com")

# Check if login fields are present.  If so, login.
needLogin = length(remDr$findElements("css", ".main input[type='text']"))
if (needLogin > 0) {
  remDr$findElement("css", ".main input[type='text']")$sendKeysToElement(list(username))
  remDr$findElement("css", ".main input[type='password']")$sendKeysToElement(list(password))
  remDr$findElement("css", ".main input[type='submit']")$clickElement()
  Sys.sleep(2)
}

# Navigate to the leaderboard URL, find table by id, store the first table in mainLeaderboard
remDr$navigate(leaderboardURL)
tableElem <- remDr$findElement(using = 'id', value = "ctl00_mainContent_dgLeaderBoard")
projTable <- readHTMLTable(header = TRUE, tableElem$getElementAttribute("outerHTML")[[1]])
mainLeaderboard <- projTable[[1]]

# Check if there is a next page button, if there is, click it and append the new leaderboard
# to the old one.  Continue this process until the next page button dissapears.
needNextPage = length(remDr$findElements(using = 'partial link text', ">"))
while (needNextPage > 0) { # if there is a next page on leaderboard, click it and append it.
  remDr$findElement(using = 'partial link text', ">")$clickElement()
  tableElem <- remDr$findElement(using = 'id', value = "ctl00_mainContent_dgLeaderBoard")
  projTable <- readHTMLTable(header = TRUE, tableElem$getElementAttribute("outerHTML")[[1]])
  tempLeaderboard <- projTable[[1]]
  mainLeaderboard = rbind(mainLeaderboard,tempLeaderboard)
  needNextPage = length(remDr$findElements(using = 'partial link text', ">"))
}
# shot = remDr$screenshot(display = TRUE) # take a screenshot
write.csv(mainLeaderboard, file=outputfile)
pJS$stop()
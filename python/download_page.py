# pip3 install selenium
from selenium import webdriver

driver = webdriver.Chrome()
driver.get('https://gohdan.ru');
html = driver.page_source
f = open("download.html", "wt")
f.write(html)
f.close()


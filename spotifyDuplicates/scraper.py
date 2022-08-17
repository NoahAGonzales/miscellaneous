from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd 
import chromedriver_binary

def findDup(url):
   # Settings
   driver = webdriver.Chrome()

   driver.get(url)

   soup = BeautifulSoup(driver.page_source, "html.parser")

   names = []
   albums = []
   artists = []

   playlist = soup.find('ol', attrs={'class':'tracklist'})

   # Find info
   for song in playlist.findAll('div', attrs={'draggable':'true'}):
      name = song.find('div', attrs={'class':'tracklist-name'}).decode_contents()
      album = song.find('a', attrs={'class':'tracklist-row__album-name-link'}).decode_contents()
      contributors = song.findAll('a', attrs={'class':'tracklist-row__artist-name-link'})

      # Find actual artist names
      for i in range(0, len(contributors)):
         contributors[i] = contributors[i].decode_contents()
      # Trim contributors (for display)
      contributors = str(contributors)
      contributors = contributors[1:len(str(contributors))-1]
      contributors = contributors.replace("'", "")


      names.append(name)
      albums.append(album)
      artists.append(contributors)

   copies = []

   # Determine if 2 songs are duplicates
   def isDuplicate(name0, name1):
      if name0.find(' mix') == -1 and name1.find(' mix') == -1 and name0.find('remix') == -1 and name1.find('remix') == -1: # exclude songs that are remixes or different mixes
         # Check if the whole name is contained in a song
         if name.find(name1) != -1 or name1.find(name0) != -1:
            return True
      return False

   # Finding possible duplicates
   for i in range(0, len(names)):
      for j in range(i+1, len(names)):
         if isDuplicate(names[i].lower(), names[j].lower()):
            copies.append([[names[i], albums[i], artists[i]], [names[j], albums[j], artists[j]]])

   duplicates = ""

   # Printing out results
   for duplicatePair in copies:
      duplicates += (duplicatePair[0][0] + ' ~ from ~ ' + duplicatePair[0][1] + ' ~ by ~ ' + duplicatePair[0][2])
      duplicates += ('\nMay be a duplicate of:\n')
      duplicates += (duplicatePair[1][0] + ' ~ from ~ ' + duplicatePair[1][1] + ' ~ by ~ ' + duplicatePair[1][2])
      duplicates += ('\n\n')

   driver.close()

   return duplicates
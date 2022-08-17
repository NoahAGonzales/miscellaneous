# spotifyDuplicates
Tool to detect if a Spotify playlist contains potential duplicates.
It has been made into an API for my personal site, but has not been implemented.

## Contents
* 

## To Run
#### Requirements:
   * Python
      * Beautifulsoup4
      * Pandas
      * Selenium
      * Chomedriver-Binary
      * Flask
      * Flask-RESTful
#### To Test (the only feature available):
   1. Execute ```python api.py``` in project directory to start local server
   2. Navigate to project directory in a separate window
   3. Execute ```curl http://localhost:5000/playlistDup -d "url=<Insert the spotify playlist url>" -X PUT```

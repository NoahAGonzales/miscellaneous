# instagramCollectionDownload
Tool to download all videos from an instagram collection

## To Run
#### Requirements:
* PowerShell 5.1 or 7 installed
* Google Chrome installed
* ChromeDriver (install the version matching the version of Google Chrome installed from [here](https://sites.google.com/chromium.org/driver/))
* Latest stable version of C# [Selenium Web Driver](https://www.selenium.dev/downloads/) (Get WebDriver.dll from the directory matching your .NET version)

#### To Test (the only feature available):
   1. Execute ```python api.py``` in project directory to start local server
   2. Navigate to project directory in a separate window
   3. Execute ```curl http://localhost:5000/playlistDup -d "url=<Insert the spotify playlist url>" -X PUT```

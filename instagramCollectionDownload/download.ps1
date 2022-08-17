

# This powershell script automates the downloading of all of the videos in an instagram collection
# Not STANDARDIZED and NO parameter validation is done
# If the value supplied for workingPath is already in the path, it will be removed as part of the cleanup for this script
# To avoid credential handling, you must already be logged into instagram on Google Chrome

param(
    # The working directory containing chromedriver.exe and WebDriver.dll
    [Parameter(Mandatory=$true)]$workingPath,
    # The directory downloaded posts will be saved in. A folder in this directory for each collection downloaded
    [Parameter(Mandatory=$true)]$downloadDirectory,
    # Comma separated list of URLs of the collections to download
    [Parameter(Mandatory=$true)]$collectionURLs,
    # Path to encrypted credentials - Created encrypted credentials xml file with  Get-Credential | Export-Clixml -Path "path"
    [Parameter(Mandatory=$true)]$credentialsPath
)

$loadWaitTime = 10

# Add the working directory to the environment path.
# This is required for the ChromeDriver to work.
$envTemp=$env:Path
if (($env:Path -split ';') -notcontains $workingPath) {
    $env:Path += ";$workingPath"
}

# Import Selenium to PowerShell using the Add-Type cmdlet.
Add-Type -Path "$($workingPath)\WebDriver.dll"

# Create a new ChromeDriver Object instance.
$ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver

# Get credentials
$credentials = Import-Clixml $credentialsPath

# Login
$ChromeDriver.Navigate().GoToURL("https://www.instagram.com/accounts/login/")
Start-Sleep -seconds $loadWaitTime
try {
    $ChromeDriver.findElement([OpenQA.Selenium.By]::Name("username")).SendKeys($credentials.Username)
    $ChromeDriver.findElement([OpenQA.Selenium.By]::Name("password")).SendKeys($credentials.GetNetworkCredential().Password)
    $ChromeDriver.findElement([OpenQA.Selenium.By]::Name("password")).SendKeys([OpenQA.Selenium.Keys]::Enter)
}
catch {
    # Exit if error entering credential to avoid entering credentials elsewhere
    Exit
}

Start-Sleep -seconds $loadWaitTime

$collectionURLs = $collectionURLs.split(',')
foreach ($URL in $collectionURLs) {
    $ChromeDriver.Navigate().GoToURL($URL)

    Start-Sleep -seconds $loadWaitTime

    $collectionLinks = $ChromeDriver.FindElements([OpenQA.Selenium.By]::CssSelector("a"))
    $postLinks = @()
    # Get post links
    foreach ($element in $collectionLinks) {
        if ($element.getAttribute("href") -like "*instagram.com/p/*") {
            $postLinks += $element.getAttribute("href")
        }
    }

    $ChromeDriver.Navigate().GoToURL("https://toolzu.com/downloader/instagram/video/")
    # Download each post
    foreach ($postLink in $postLinks) {
        # Enter link
        $ChromeDriver.FindElement([OpenQA.Selenium.By]::Id("instagramdownloaderform-search")).SendKeys($postLink)
        $ChromeDriver.FindElement([OpenQA.Selenium.By]::Id("instagramdownloaderform-search")).SendKeys([OpenQA.Selenium.Keys]::Enter)

        # Select download button

        # Enter Windows dialog text

        Start-Sleep -seconds 30

        # Clear text field
        $ChromeDriver.FindElement([OpenQA.Selenium.By]::Id("instagramdownloaderform-search")).SendKeys([OpenQA.Selenium.Keys]::Control + "A")
        Start-Sleep -seconds 1
        $ChromeDriver.FindElement([OpenQA.Selenium.By]::Id("instagramdownloaderform-search")).SendKeys([OpenQA.Selenium.Keys]::Delete)
        Start-Sleep -seconds 1
        
    }
    
    Start-Sleep -seconds $loadWaitTime
}

Start-Sleep -seconds 10

# Cleanup driver
$ChromeDriver.Close()
$ChromeDriver.Quit()

# Restore path
#$env:path = $envTemp
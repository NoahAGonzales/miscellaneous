

# This powershell script automates the downloading of all of the videos in an instagram collection
# Not STANDARDIZED and NO parameter validation is done
# If the value supplied for workingPath is already in the path, it will be removed as part of the cleanup for this script
# To avoid credential handling, you must already be logged into instagram on Google Chrome

param(
    # The working directory containing chromedriver.exe and WebDriver.dll
    [Parameter(Mandatory=$true)]$workingPath,
    # Comma separated list of URLs of the collections to download
    [Parameter(Mandatory=$true)]$collectionURLs,
    # Path to encrypted credentials - Created encrypted credentials xml file with  Get-Credential | Export-Clixml -Path "path"
    [Parameter(Mandatory=$true)]$credentialsPath
)

$debug = $false

$loadWaitTime = 10
$videoProcessingWaitTime = 15
$actionWaitTime = 1

# Add the working directory to the environment path.
# This is required for the ChromeDriver to work.
if (($env:Path -split ';') -notcontains $workingPath) {
    $env:Path += ";$workingPath"
}

# Import Selenium to PowerShell using the Add-Type cmdlet.
Add-Type -Path "$($workingPath)\WebDriver.dll"

# Create a new ChromeDriver Object instance.
$ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver
$ChromeDriver.manage().Window.maximize()

# Get credentials
$credentials = Import-Clixml $credentialsPath

# Login
if ($debug) {"DEBUG: Navigating to instagram"}
$ChromeDriver.Navigate().GoToURL("https://www.instagram.com/accounts/login/")
Start-Sleep -seconds $loadWaitTime
try {
    $ChromeDriver.findElement([OpenQA.Selenium.By]::Name("username")).SendKeys($credentials.Username)
    $ChromeDriver.findElement([OpenQA.Selenium.By]::Name("password")).SendKeys($credentials.GetNetworkCredential().Password)
    Start-Sleep -seconds $actionWaitTime
    $ChromeDriver.findElement([OpenQA.Selenium.By]::Name("password")).SendKeys([OpenQA.Selenium.Keys]::Enter)
}
catch {
    # Exit if error entering credential to avoid entering credentials elsewhere
    "Error entering credentials - exiting" | Write-Output
    Exit
}

Start-Sleep -seconds $loadWaitTime

$collectionURLs = $collectionURLs.split(',')
foreach ($URL in $collectionURLs) {
    # Navigate to collection
    $ChromeDriver.Navigate().GoToURL($URL)
    Start-Sleep -seconds $loadWaitTime

    $postLinks = @{}

    #  Capture links and then scroll down to load videos
    $body = $ChromeDriver.findElement([OpenQA.Selenium.By]::CssSelector("body"))
    for ($i=0;$i -lt 20;$i++) {

        # Get Collection links
        if ($debug) {"DEBUG: Getting collection links"}
        $collectionLinks = $ChromeDriver.FindElements([OpenQA.Selenium.By]::CssSelector("a"))
        # Get post links from collection links
        foreach ($element in $collectionLinks) {
            #$element.getAttribute("href") | Write-Output
            if ($element.getAttribute("href") -like "*instagram.com/p/*" ) {
                $postLinks[$element.getAttribute("href")] = $true
            }
        }

        # Scroll
        if ($debug) {"DEBUG: Scrolling down x$i"}
        $ChromeDriver.ExecuteScript("window.scrollBy(0,1000)")
        Start-Sleep -seconds $loadWaitTime
    }

    # Output post links
    '' + $postLinks.Count + " posts to download:" | Write-Output
    $postLinks.Keys | Write-Output
    "---" | Write-Output

    # Go to download site
    if ($debug) {"DEBUG: Navigating to download site"}
    $ChromeDriver.Navigate().GoToURL("https://igpanda.com/")
    Start-Sleep -seconds $loadWaitTime

    # Click on type
    if ($debug) {"DEBUG: Selecting type"}
    $ChromeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="url-form"]/div[1]/div/div/div/div[2]/a')).Click()
    Start-Sleep -seconds $actionWaitTime

    # Download each post
    foreach ($postLink in $postLinks.keys) {
        # Enter link
        if ($debug) {"DEBUG: Entering post link"}
        $urlTextField = $ChromeDriver.FindElement([OpenQA.Selenium.By]::Id("url"))
        $urlTextField.SendKeys($postLink)
        $urlTextField.SendKeys([OpenQA.Selenium.Keys]::Enter)

        # Site downloading video may take some time
        Start-Sleep -seconds $videoProcessingWaitTime

        # Clear text field
        if ($debug) {"DEBUG: Clearing text field"}
        $urlTextField.SendKeys([OpenQA.Selenium.Keys]::Control + "A")
        Start-Sleep -seconds $actionWaitTime
        $urlTextField.SendKeys([OpenQA.Selenium.Keys]::Delete)
        Start-Sleep -seconds $actionWaitTime

        try {
            if ($debug) {"DEBUG: Clicking on download button"}
            # Click download button
            $downloadButton = $ChromeDriver.FindElement([OpenQA.Selenium.By]::XPath(('//*[@id="home"]/div/div[1]/div/div/div/div/div/div/div/div/a')))
            $downloadButton.Click()
            Start-Sleep -seconds $actionWaitTime
        }
        catch {
            # Error downloading video
            "Error downloading $postLink" | Write-Output
            continue
        }

        Start-Sleep -seconds $actionWaitTime
    }
}

# Wait for last download
Start-Sleep -seconds 30

# Cleanup driver
$ChromeDriver.Close()
$ChromeDriver.Quit()
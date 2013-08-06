function Get-WIAStatusValue($value)

{

switch -exact ($value)

{

0 {"NotStarted"}

1 {"InProgress"}

2 {"Succeeded"}

3 {"SucceededWithErrors"}

4 {"Failed"}

5 {"Aborted"}

}

}




$needsReboot = $false

$UpdateSession = New-Object -ComObject Microsoft.Update.Session

$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

Write-Host " - Searching for Updates"

$SearchResult = $updateSession.createupdatesearcher().search("isInstalled=0 and Type='Software'").Updates | Where-Object { $_.MsrcSeverity -eq "Critical" }

#$criticalSearchResult = $SearchResult | Where-Object { $_.Msrcseverity="Critical"}

Write-Host " - Found [$($SearchResult.count)] Updates to Download and install"

Write-Host

foreach($Update in $SearchResult)

{

# Add Update to Collection

$UpdatesCollection = New-Object -ComObject Microsoft.Update.UpdateColl

if ( $Update.EulaAccepted -eq 0 ) { $Update.AcceptEula() }

$UpdatesCollection.Add($Update) 




# Download

Write-Host " + Downloading Update $($Update.Title)"

$UpdatesDownloader = $UpdateSession.CreateUpdateDownloader()

$UpdatesDownloader.Updates = $UpdatesCollection

$DownloadResult = $UpdatesDownloader.Download()

$Message = " - Download {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)

Write-Host $message

# Install

Write-Host " - Installing Update"

$UpdatesInstaller = $UpdateSession.CreateUpdateInstaller()

$UpdatesInstaller.Updates = $UpdatesCollection

$InstallResult = $UpdatesInstaller.Install()

$Message = " - Install {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)

Write-Host $message

Write-Host

$needsReboot = $installResult.rebootRequired

}

if($needsReboot)

{

restart-computer

}



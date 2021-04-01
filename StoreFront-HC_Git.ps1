<#
.Synopsis
   This script checks a Citrix StoreFront
.DESCRIPTION
   This script checks a Citrix StoreFront and generates a HTML output File which will be sent as Email.
.EXAMPLE
   Create a schedtasks and run everty day at morning
.EXAMPLE
   Run directly from ISE. 
.BASED ON
   Original script was created by Sacha Thomet sachatomet.ch, but I think this was discontinued because it's 
   latest version is from Mar 18, 2019
.PRE-REQUIREMENTS
   Run on a Store Front Server.
.TESTED ON
   Tested on Store Front 3.22 Build 1000 Revision 17
.HISTORY
    .Version 0.1
    Initial Version
    Added Check of Services: CitrixCredentialWalletSvC CitrixPeerResolutionSvC 
    .Version 0.3
    Initial Version
    Added Check of Services: WWWService
    Add Check's in deployment: URLReachable LastSourceServer LastSyncStatus LastSyncTime 

    .Version 0.4 (julianoabr)
    Added Function to Check more services
    Created a Function to Send Mail
     

#>



$scriptstart = Get-Date

$mailDate = Get-Date -Format "dddd /dd/MM/yyyy HH:mm K"

#==============================================================================================

if ((Get-PSSnapin "Citrix.*" -ErrorAction SilentlyContinue) -eq $null) {
    try { 
        Add-PSSnapin Citrix.* -ErrorAction Stop
    }
    catch { 
    
    Write-Error "Error Get-PSSnapin Citrix.* Powershell snapin"; Return }

}

& "C:\Program Files\Citrix\Receiver StoreFront\Scripts\ImportModules.ps1" 

#==============================================================================================

$currentDir = Split-Path $MyInvocation.MyCommand.Path

$logfile = Join-Path $currentDir ("StorefrontHealthCheck.log")

$outputDateReport = (Get-Date -Format 'ddMMyyyy-HHmm').ToString()

$resultsHTM = Join-Path $currentDir ("StorefrontReport-$outputDateReport.htm")

$errorsHTM = Join-Path $currentDir ("StorefrontHealthCheckErrors.htm") 

$ReportDate = (Get-Date -UFormat "%A, %d de %B de %Y - %R").ToString()


#==============================================================================================
#Function to Send Mail
function Send-PSMail
{
    [CmdletBinding()]
    [Alias("spsmail")]
    Param
    (
        [parameter(
               Mandatory=$false,
               HelpMessage='Activates the e-mail sending feature ($true/$false). The default value is "$false"',
               Position=0)]
               [System.Boolean]$sendMail = $true,
       
        [parameter(
                Mandatory=$false,
                HelpMessage='SMTP Server Address (Like IP address, hostname or FQDN)',
                Position=1)]
                [System.String]$smtpServer = "yoursmtpserver.com",

        [parameter(
                Mandatory=$false,
                HelpMessage='SMTP Server port number (Default 25)',
                Position=2)]
                [ValidateSet(25,587,465,2525)]
                [int]$smtpPort = "25",
        [parameter(
                Mandatory=$false,
                HelpMessage='Sender e-mail address',
                Position=3)]
                [System.String]$mailFrom = "powershellrobot@yourcompany.com",

        [parameter(
                Mandatory=$false,
                HelpMessage='Recipient e-mail address',
                Position=4)]
               [System.String[]]$mailTo = ("yourteam@yourcompany.com","yourteam2@yourcompany.com"),
                 
                 
        [parameter(
                Mandatory=$false,
                HelpMessage='Copied e-mail address',
                Position=5)]
               [System.String[]]$mailCC = "yourteam3@yourcompany.com",
                      
        [parameter(
                Mandatory=$false,
                HelpMessage='Subject of E-mail',
                Position=6)]
                [System.String]$mailSubject = "[YOUR-COMPANY] StoreFront Farm Report - $mailDate ",

        [parameter(
                Mandatory=$false,
                HelpMessage='If Body of e-mail is HTML',
                Position=7)]
                [System.Boolean]$htmlBody=$true,

        
        [parameter(
                Mandatory=$false,
                HelpMessage='Body of E-mail',
                Position=8)]
                [System.String]$mailMsgBody,
        
        [parameter(
                Mandatory=$false,
                HelpMessage='Mail Priority',
                Position=9)]
                [ValidateSet('High','Low','Normal')]
                [System.String]$mailPriority = 'Normal',
                      
        [parameter(
                Mandatory=$false,
                HelpMessage='Encoding Language',
                Position=10)]
                [ValidateSet('ASCII','UTF8','UTF7','UTF32','Unicode','BigEndianUnicode','Default','OEM')]
                [System.String]$mailEncoding = 'UTF8',
        
        [parameter(
                Mandatory=$false,
                HelpMessage='Attachments',
                Position=11)]
                [System.String[]]$mailAttachments 

    )

#VERIFY SEND MAIL
if ($SendMail){
        
    if ($htmlBody){
    
        Send-MailMessage -SmtpServer $SmtpServer -Port $smtpPort -From $mailFrom -To $mailTo -Cc $mailCC -Subject $mailSubject -BodyAsHtml $mailMsgBody -Attachments $mailAttachments -Priority $mailPriority -Encoding $mailEncoding
    
    
    }#end of if HTML BODY
    else{
    
         Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort -From $MailFrom -To $MailTo -Cc $MailCC -Subject $MailSubject -Body $MailMsgBody -Attachments $mailAttachments -Priority $MailPriority -Encoding $MailEncoding
    
    
    }#end of Else Not Send HTML BODY
    

}
else{


   Write-Host "Send E-mail is defined to: $SendMail. So I will not send =D" -ForegroundColor White -BackgroundColor DarkGreen

}
    

}#End of Function


#==============================================================================================

#Header for Table 1 "DeploymentCheck Get-STFDeployment""
$DeploymentFirstHeaderName = "SiteId"
$DeploymentHeaderName = "HostbaseUrl", "URLReachable", "LastSourceServer","LastSyncStatus","LastSyncTime", "LastErrorMessage"
$DeploymentWidths =     "4",            "4",               "4",             "4",            "4",           "12"
$DeploymentTableWidth  = 800

#Header for Table 2 "Clustermembers"
$ClusterMemberFirstFarmheaderName = "StoreFrontServer"


$diskLettersStoreFront = @()

#ADD MORE LETTERS TO THIS ARRAY. Example: 'C','D','E'
$diskLettersStoreFront = 'C'

$ClusterMemberHeaderNames = "AvgCPU","MemUsg"
$ClusterMemberWidths =      "4",     "4",     "4"
foreach ($disk in $diskLettersStoreFront)
{
    $ClusterMemberHeaderNames += "$($disk)Freespace"
    $ClusterMemberWidths += "4"
}
$ClusterMemberHeaderNames += "EventsLogLast24h"
$ClusterMemberWidths += "4"

$ClusterMemberTablewidth  = 800


#Header for Table 3 "Services"
$ClusterSvcFirstFarmheaderName = "StoreFrontServer"
$ClusterSvcHeaderNames = "CitrixPeerResolutionSvc","CitrixClusterJoinSvc","CitrixConfigurationRepl","CitrixCredentialWallet","CitrixDefaultDomainSvcs","CitrixStorefrontPrivilegedAdmSvc","CitrixSvcMonitor","CitrixSubscriptionsStore","CitrixTelemetrySvc","WWWPublishingService"
$ClusterSvcWidths =      "8", "8", "8", "8", "8", "8","8","8","8","8"
$ClusterSvcTablewidth  = 800


#==============================================================================================
#Table Footer Info

$thisServer = $env:COMPUTERNAME

$today = (get-date)

$lastBoot = Get-cimInstance -className Win32_operatingsystem | Select-Object -ExpandProperty lastbootuptime

$diff = New-TimeSpan -Start $lastBoot -End $today

$tDays = $diff.Days.ToString()

$tHours = $diff.Hours.ToString()

$STFVersion = Get-STFVersion

$STFMajor = $STFVersion.Major

$STFMinor = $STFVersion.Minor

$STFBuild = $STFVersion.Build

$STFRevision = $STFVersion.Revision

#==============================================================================================


#==============================================================================================
#log function
function LogMe() {
Param(
[parameter(Mandatory = $true, ValueFromPipeline = $true)] $logEntry,
[switch]$display,
[switch]$error,
[switch]$warning,
[switch]$progress
)
  
if ($error) { $logEntry = "[ERROR] $logEntry" ; Write-Host "$logEntry" -Foregroundcolor Red }
elseif ($warning) { Write-Warning "$logEntry" ; $logEntry = "[WARNING] $logEntry" }
elseif ($progress) { Write-Host "$logEntry" -Foregroundcolor Green }
elseif ($display) { Write-Host "$logEntry" }
  
#$logEntry = ((Get-Date -uformat "%D %T") + " - " + $logEntry)
$logEntry | Out-File $logFile -Append
}

#==============================================================================================

function Ping([string]$hostname, [int]$timeout = 50) {
$ping = new-object System.Net.NetworkInformation.Ping #creates a ping object
try { $result = $ping.send($hostname, $timeout).Status.ToString() }
catch { $result = "Failure" }
return $result
}


#==============================================================================================
# The function will check the processor counter and check for the CPU usage. Takes an average CPU usage for 5 seconds. It check the current CPU usage for 5 secs.
Function CheckCpuUsage() 
{ 
	param ($hostname)
	Try { $CpuUsage=(Get-WmiObject -ComputerName $hostname -class win32_processor -ErrorAction Stop | Measure-Object -property LoadPercentage -Average | Select-Object -ExpandProperty Average)
    $CpuUsage = [math]::round($CpuUsage, 1); return $CpuUsage


	} Catch { "Error returned while checking the CPU usage. Perfmon Counters may be fault" | LogMe -error; return 101 } 
}
#============================================================================================== 


#============================================================================================== 
# The function check the memory usage and report the usage value in percentage
Function CheckMemoryUsage()
{ 
	param ($hostname)
    Try 
	{   $SystemInfo = (Get-WmiObject -ComputerName $hostname -Class Win32_OperatingSystem -ErrorAction Stop | Select-Object TotalVisibleMemorySize, FreePhysicalMemory)
    	$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB 
    	$FreeRAM = $SystemInfo.FreePhysicalMemory/1MB 
    	$UsedRAM = $TotalRAM - $FreeRAM 
    	$RAMPercentUsed = ($UsedRAM / $TotalRAM) * 100 
    	$RAMPercentUsed = [math]::round($RAMPercentUsed, 2);
    	return $RAMPercentUsed
	} Catch { "Error returned while checking the Memory usage. Perfmon Counters may be fault" | LogMe -error; return 101 } 
}
#==============================================================================================

# The function check the HardDrive usage and report the usage value in percentage and free space
Function CheckHardDiskUsage() 
{ 
	param ($hostname, $deviceID)
    Try 
	{   
    	$HardDisk = $null
		$HardDisk = Get-WmiObject -ComputerName $hostname -Class Win32_LogicalDisk -Filter "DeviceID='$deviceID'" -ErrorAction Stop | Select-Object Size,FreeSpace
        if ($null -ne $HardDisk)
		{
		$DiskTotalSize = $HardDisk.Size 
        $DiskFreeSpace = $HardDisk.FreeSpace 
        $frSpace=[Math]::Round(($DiskFreeSpace/1073741824),2)
		$PercentageDS = (($DiskFreeSpace / $DiskTotalSize ) * 100); $PercentageDS = [math]::round($PercentageDS, 2)
		
		Add-Member -InputObject $HardDisk -MemberType NoteProperty -Name PercentageDS -Value $PercentageDS
		Add-Member -InputObject $HardDisk -MemberType NoteProperty -Name frSpace -Value $frSpace
		} 
		
    	return $HardDisk
	} Catch { "Error returned while checking the Hard Disk usage. Perfmon Counters may be fault" | LogMe -error; return $null } 
}

# ==============================================================================================

Function writeHtmlHeader
{
param($title, $fileName)
$date = $ReportDate
$head = @"
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
<title>$title</title>
<STYLE TYPE="text/css">
<!--
td {
font-family: Tahoma;
font-size: 11px;
border-top: 1px solid #999999;
border-right: 1px solid #999999;
border-bottom: 1px solid #999999;
border-left: 1px solid #999999;
padding-top: 0px;
padding-right: 0px;
padding-bottom: 0px;
padding-left: 0px;
overflow: hidden;
}
body {
margin-left: 5px;
margin-top: 5px;
margin-right: 0px;
margin-bottom: 10px;
table {
table-layout:fixed;
border: thin solid #000000;
}
-->
</style>
</head>
<body>
<table width='1200'>
<tr bgcolor='#CCCCCC'>
<td colspan='7' height='48' align='center' valign="middle">
<font face='tahoma' color='#003399' size='4'>
<strong>$title - $date</strong></font>
</td>
</tr>
</table>
"@
$head | Out-File $fileName
}

# ==============================================================================================

Function writeTableHeader
{
param($fileName, $firstheaderName, $headerNames, $headerWidths, $tablewidth)
$tableHeader = @"
  
<table width='$tablewidth'><tbody>
<tr bgcolor=#CCCCCC>
<td width='6%' align='center'><strong>$firstheaderName</strong></td>
"@
  
$i = 0
while ($i -lt $headerNames.count) {
$headerName = $headerNames[$i]
$headerWidth = $headerWidths[$i]
$tableHeader += "<td width='" + $headerWidth + "%' align='center'><strong>$headerName</strong></td>"
$i++
}
  
$tableHeader += "</tr>"
  
$tableHeader | Out-File $fileName -append
}

# ==============================================================================================

Function writeTableFooter
{
param($fileName)
"</table><br/>"| Out-File $fileName -append
}

# ==============================================================================================

Function writeData
{
param($data, $fileName, $headerNames)

$tableEntry  =""  
$data.Keys | Sort-Object | ForEach-Object {
$tableEntry += "<tr>"
$computerName = $_
$tableEntry += ("<td bgcolor='#CCCCCC' align=center><font color='#003399'>$computerName</font></td>")
#$data.$_.Keys | foreach {
$headerNames | ForEach-Object {
#"$computerName : $_" | LogMe -display
try {
if ($data.$computerName.$_[0] -eq "SUCCESS") { $bgcolor = "#387C44"; $fontColor = "#FFFFFF" }
elseif ($data.$computerName.$_[0] -eq "WARNING") { $bgcolor = "#FF7700"; $fontColor = "#FFFFFF" }
elseif ($data.$computerName.$_[0] -eq "ERROR") { $bgcolor = "#FF0000"; $fontColor = "#FFFFFF" }
else { $bgcolor = "#CCCCCC"; $fontColor = "#003399" }
$testResult = $data.$computerName.$_[1]
}
catch {
$bgcolor = "#CCCCCC"; $fontColor = "#003399"
$testResult = ""
}
$tableEntry += ("<td bgcolor='" + $bgcolor + "' align=center><font color='" + $fontColor + "'>$testResult</font></td>")
}
$tableEntry += "</tr>"
}
$tableEntry | Out-File $fileName -append
}

#==============================================================================================
<#
Function writeHtmlFooter
{
param($fileName)
@"
<table>
<table width='1200'>
<tr bgcolor='#CCCCCC'>
<td colspan='7' height='25' align='left'>
<br>
<font face='courier' color='#000000' size='2'>
<strong>Script Runs on Server:</strong></font><font color='#003399' face='courier' size='2'> $env:Computername<tr></font><br>
<tr bgcolor='#CCCCCC'>
</td>
</tr>
<tr bgcolor='#CCCCCC'>
</tr>
</table>
</body>
</html>
"@ | Out-File $FileName -append
}
#>

Function writeHtmlFooter
{
param($fileName)
@"
</table>
<table width='1200'>
<tr bgcolor='#CCCCCC'>
<td colspan='7' height='25' align='left'>
<font face='courier' color='#000000' size='2'>

<strong>Script Runs On: </strong> $thisServer <br>
<strong>Uptime Days: </strong> $tDays <strong>Uptime Hours: </strong> $tHours <br>
<strong>StoreFront Major Version: </strong> $STFMajor <strong>Minor Version: </strong> $STFMinor <br>
<strong>Build: </strong> $STFBuild <br>
<strong>Revision: </strong> $STFRevision <br>

</font>
</td>
</table>
</body>
</html>
"@ | Out-File $FileName -append
}



#==============================================================================================

function Deployment-Check {
# =======  Check ====================================================================
"Deployment Check Running..." | LogMe -display -progress

" " | LogMe -display -progress

$global:DeploymentResults = @{}

$STFDeployment = Get-STFDeployment

$global:DeploymentSiteId = $STFDeployment.SiteId 

"StoreFront Deployment SiteId: $global:DeploymentSiteId" | LogMe -display -progress

$STFDeploymenttests = @{}

$DeploymentHostbaseUrl = $STFDeployment | %{ $_.HostbaseUrl}

$STFDeploymenttests.HostbaseUrl = "NEUTRAL", $DeploymentHostbaseUrl

"StoreFront HostbaseUrl: $DeploymentHostbaseUrl" | LogMe -display -progress

#HTTP Check
# => currently not working
#   $HTTP_Request = [System.Net.WebRequest]::Create($DeploymentHostbaseUrl)
#   $httpstatus = $HTTP_Request.HaveResponse
#   $httpstatus = $HTTP_Request.GetResponse() | select StatusCode
#   $httpstatus.StatusCode

#Edit by JKU

#by Alain Assaf to enable TLS 1.2 instead 1.0 - if you use TLS1.0 remove next line
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$httpstatus = (Invoke-WebRequest -Uri $DeploymentHostbaseUrl -Method Get -UseBasicParsing)

if ($httpstatus.StatusDescription -ne "OK") { $STFDeploymenttests.URLReachable = "ERROR", $httpstatus.StatusCode }
else { $STFDeploymenttests.URLReachable = "SUCCESS", $httpstatus.StatusCode}`


#ReplicationChecks (Registry)
$ConfigurationReplicationSource = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication' -Name LastSourceServer).LastSourceServer
$syncsctate = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication' -Name LastUpdateStatus).LastUpdateStatus
$endsyncdate = (Get-ItemProperty -Path  'HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication' -Name LastEndTime).LastEndTime
$lastErrorMessage = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication' -Name LastErrorMessage).LastErrorMessage


$STFDeploymenttests.LastSourceServer = "NEUTRAL", $ConfigurationReplicationSource

if ($syncsctate -ne "Complete") { 
    
    $STFDeploymenttests.LastSyncStatus = "ERROR", $syncsctate
}
else{
    
    $STFDeploymenttests.LastSyncStatus = "SUCCESS", $syncsctate
}

$STFDeploymenttests.LastSyncTime = "NEUTRAL", $endsyncdate


if ($lastErrorMessage -eq ''){

    $STFDeploymenttests.LastErrorMessage = "SUCCESS",$lastErrorMessage

}
else{

    $STFDeploymenttests.LastErrorMessage = "ERROR",$lastErrorMessage

}

$global:DeploymentResults.$global:DeploymentSiteId = $STFDeploymenttests

}

#==============================================================================================

function Cluster-MemberCheck {

"Cluster Member Check Function Running..." | LogMe -display -progress

" " | LogMe -display -progress

$global:ClusterMemberResults = @{}

$clMembers = (Get-STFServerGroup).ClusterMembers

$global:hostNames = $clMembers.Hostname

foreach($STFServerName in $hostNames){

    $ClusterMembertests = @{}

    $STFServerName
    
    "StoreFront-Server: $STFServerName " | LogMe -display -progress

    # Ping server 
    $result = Ping $STFServerName -timeout 50

    "Ping: $result" | LogMe -display -progress

    if ($result -ne "SUCCESS"){ 

        $ClusterMembertests.Ping = "ERROR", $result

    }#End of IF Ping
    else { 

        $ClusterMembertests.Ping = "SUCCESS", $result 
    
#==============================================================================================
#               CHECK CPU AND MEMORY USAGE 
#==============================================================================================

       # Check the AvgCPU value for 5 seconds
       $AvgCPUval = CheckCpuUsage ($STFServerName)
		if( [int] $AvgCPUval -lt 75) { "CPU usage is normal [ $AvgCPUval % ]" | LogMe -display; $ClusterMembertests.AvgCPU = "SUCCESS", "$AvgCPUval %" }
		elseif([int] $AvgCPUval -lt 85) { "CPU usage is medium [ $AvgCPUval % ]" | LogMe -warning; $ClusterMembertests.AvgCPU = "WARNING", "$AvgCPUval %" }   	
		elseif([int] $AvgCPUval -lt 95) { "CPU usage is high [ $AvgCPUval % ]" | LogMe -error; $ClusterMembertests.AvgCPU = "ERROR", "$AvgCPUval %" }
		elseif([int] $AvgCPUval -eq 101) { "CPU usage test failed" | LogMe -error; $ClusterMembertests.AvgCPU = "ERROR", "Err" }
       else { "CPU usage is Critical [ $AvgCPUval % ]" | LogMe -error; $ClusterMembertests.AvgCPU = "ERROR", "$AvgCPUval %" }   
		$AvgCPUval = 0

       # Check the Physical Memory usage       
       $UsedMemory = CheckMemoryUsage ($STFServerName)
       if( [int] $UsedMemory -lt 75) { "Memory usage is normal [ $UsedMemory % ]" | LogMe -display; $ClusterMembertests.MemUsg = "SUCCESS", "$UsedMemory %" }
		elseif([int] $UsedMemory -lt 85) { "Memory usage is medium [ $UsedMemory % ]" | LogMe -warning; $ClusterMembertests.MemUsg = "WARNING", "$UsedMemory %" }   	
		elseif([int] $UsedMemory -lt 95) { "Memory usage is high [ $UsedMemory % ]" | LogMe -error; $ClusterMembertests.MemUsg = "ERROR", "$UsedMemory %" }
		elseif([int] $UsedMemory -eq 101) { "Memory usage test failed" | LogMe -error; $ClusterMembertests.MemUsg = "ERROR", "Err" }
       else { "Memory usage is Critical [ $UsedMemory % ]" | LogMe -error; $ClusterMembertests.MemUsg = "ERROR", "$UsedMemory %" }   
		$UsedMemory = 0  
        
       # Check Disk Usage
       $diskLetters = @() 
       
       $diskLetters = Get-WmiObject -ComputerName $STFServerName -Class win32_logicaldisk | Select-Object -ExpandProperty DeviceID
       
       $diskLettersStoreFront = $diskLetters -replace (":","")
       
       foreach ($disk in $diskLettersStoreFront)
        {
            # Check Disk Usage 
		    $HardDisk = CheckHardDiskUsage -hostname $STFServerName -deviceID "$($disk):"
		    if ($null -ne $HardDisk) {	
			    
                $SFPercentageDS = $HardDisk.PercentageDS
			    
                $frSpace = $HardDisk.frSpace
			
	            If ( [int] $SFPercentageDS -gt 15) { "Disk Free is normal [ $SFPercentageDS % ]" | LogMe -display; $ClusterMembertests."$($disk)Freespace" = "SUCCESS", "$frSpace GB" } 
			    ElseIf ([int] $SFPercentageDS -eq 0) { "Disk Free test failed" | LogMe -error; $ClusterMembertests."$($disk)Freespace" = "ERROR", "Err" }
			    ElseIf ([int] $SFPercentageDS -lt 5) { "Disk Free is Critical [ $SFPercentageDS % ]" | LogMe -error; $ClusterMembertests."$($disk)Freespace" = "ERROR", "$frSpace GB" } 
			    ElseIf ([int] $SFPercentageDS -lt 15) { "Disk Free is Low [ $SFPercentageDS % ]" | LogMe -warning; $ClusterMembertests."$($disk)Freespace" = "WARNING", "$frSpace GB" }     
	            Else { "Disk Free is Critical [ $SFPercentageDS % ]" | LogMe -error; $ClusterMembertests."$($disk)Freespace" = "ERROR", "$frSpace GB" }  
        
			    $SFPercentageDS = 0
			    $frSpace = 0
			    $HardDisk = $null
		    }
        }


#==============================================================================================
#               CHECK EventLog Last 24 h
#==============================================================================================
$LogEventsLast24 = ""

$LogEventsLast24 = Get-EventLog -ComputerName $STFServerName -LogName 'Citrix Delivery Services' -After (Get-date).AddHours(-24)


$ClusterMembertests.EventsLogLast24h = "NEUTRAL", $LogEventsLast24.Count  


        }#End of Else Ping

    $global:ClusterMemberResults.$STFServerName = $ClusterMembertests
            
    }#End of ForEach Store Front Server Verification

}


#==============================================================================================
#               CHECK SERVICES 
#==============================================================================================

function Cluster-SVCCheck {

"Cluster SVC Function Check Services..." | LogMe -display -progress

" " | LogMe -display -progress

$global:ClusterSvcResults = @{}

foreach($STFServerName in $hostnames){

$ClusterSvctests = @{}   

$storeFrontSvcList = @(
('Citrix Peer Resolution Service','CitrixPeerResolutionSvc'),
('CitrixClusterService','CitrixClusterJoinSvc'),
('CitrixConfigurationReplication','CitrixConfigurationRepl'),
('CitrixCredentialWallet','CitrixCredentialWallet'),
('CitrixDefaultDomainService','CitrixDefaultDomainSvcs'),
('CitrixPrivilegedService','CitrixStorefrontPrivilegedAdmSvc'),
('CitrixServiceMonitor','CitrixSvcMonitor'),
('CitrixSubscriptionsStore','CitrixSubscriptionsStore'),
('CitrixTelemetryService','CitrixTelemetrySvc'),
('W3SVC','WWWPublishingService')
)

#VERIFY EACH SERVICE
    foreach ($storeFrontSVC in $storeFrontSvcList)
    {
    
        $storeFrontSVCName = $storeFrontSVC[0]

        $storeFrontSVCDisplayName = $storeFrontSVC[1]


        if ((Get-Service -Name $storeFrontSVCName -ComputerName $STFServerName).StartType -match "Disabled"){
    
            "$storeFrontSVCDisplayName disabled..." | LogMe
        
            $ClusterSvctests.$storeFrontSVCDisplayName = "WARNING", "Warning"
                
        }#end of IF Service Disabled
        else{
    
            if ((Get-Service -Name $storeFrontSVCName -ComputerName $STFServerName).Status -Match "Running") {
			
                "$storeFrontSVCDisplayName running..." | LogMe
			
                $ClusterSvctests.$storeFrontSVCDisplayName = "SUCCESS", "Success"

            }#end of If Matching Running
            else{

	            "$storeFrontSVCDisplayName service stopped"  | LogMe -display -error
			
                $ClusterSvctests.$storeFrontSVCDisplayName = "ERROR", "Error"

	        }#End of Else Matching Running
    
        }#end of Else Service Disabled

    }#End of ForEach StoreFrontSVC


$global:ClusterSvcResults.$STFServerName = $ClusterSvctests

}#end of Foreach Server svc



}#end of Function Cluster SVC Check

#==============================================================================================


#HTML function
function WriteHTML() {

# ======= Write all results to an html file =================================================
Write-Host ("Saving results to html report: " + $resultsHTM)

writeHtmlHeader "StoreFront  Report " $resultsHTM

#TABLE 1
writeTableHeader $resultsHTM $DeploymentFirstHeaderName $DeploymentHeaderName $DeploymentWidths $DeploymentTableWidth

$global:DeploymentResults | Sort-Object -Property SiteId | % { writeData $DeploymentResults $resultsHTM $DeploymentHeaderName}

writeTableFooter $resultsHTM

#TABLE 2
writeTableHeader $resultsHTM $ClusterMemberFirstFarmheaderName $ClusterMemberHeaderNames $ClusterMemberWidths $ClusterMemberTablewidth

$global:DeploymentResults | Sort-Object -Property STFServerName | % { writeData $ClusterMemberResults $resultsHTM $ClusterMemberHeaderNames}

writeTableFooter $resultsHTM

#TABLE 3
writeTableHeader $resultsHTM $ClusterSvcFirstFarmheaderName $ClusterSvcHeaderNames $ClusterSvcWidths $ClusterSvcTablewidth

$global:DeploymentResults | Sort-Object -Property STFServerName | % {writeData $ClusterSvcResults $resultsHTM $ClusterSvcHeaderNames}

writeTableFooter $resultsHTM

writeHtmlFooter $resultsHTM
}

#==============================================================================================
# == MAIN SCRIPT ==
#==============================================================================================
rm $logfile -force -EA SilentlyContinue

"Begin with Citrix StoreFront HealthCheck" | LogMe -display -progress

" " | LogMe -display -progress

Deployment-Check

Cluster-MemberCheck

Cluster-SVCCheck

WriteHTML

#==============================================================================================
# == SEND MAIL ==
#==============================================================================================
$htmMsgBody = (Get-Content $resultsHTM) | Out-String

Send-PSMail -mailAttachments $resultsHTM -mailMsgBody $htmMsgBody

#==============================================================================================

$scriptend = Get-Date
$scriptruntime =  $scriptend - $scriptstart | select TotalSeconds
$scriptruntimeInSeconds = $scriptruntime.TotalSeconds
#Write-Host $scriptruntime.TotalSeconds
"Script was running for $scriptruntimeInSeconds seconds" | LogMe -display -progress
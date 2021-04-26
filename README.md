- 👋 Hi, I’m @mehdigharibi
- 👀 I’m interested in Programming , Network Security , Malware Malware Analysis Papers Only :D
- 🌱 I’m currently learning Dart/Flutter
- 💞️ I’m looking to collaborate on nothing
- 📫 How to reach me just think !


Problem : RDP attack !!?
Microsoft's Remote Desktop Protocol has become a popular attack vector. Here's what you need to know about the threat.

Over the past year, RDP has become the top attack vector for ransomware. Threat actors have repeatedly exploited internet-exposed RDP services to install ransomware on systems and networks belonging to numerous major organizations. In July, the SamSam group infected some 7,000 Windows PCs and 1,900 servers at LabCorp with ransomware via a brute force attack on an RDP server. In another incident this year, Hancock Health was forced to pay over $50,000 in ransom to regain access to critical data that criminals had encrypted after breaking into its network via a hospital server running RDP services.

Attackers have also exploited RDP to install cryptomining tools, keyloggers, backdoors and other malware on enterprise systems. Many have used RDP services to establish a foothold on an enterprise network, to elevate privileges, harvest credentials, to move laterally inside a compromised environment and to plant false flags for misdirection purposes.

Source of This information : https://www.csoonline.com/article/3304306/what-is-an-rdp-attack-7-tips-for-mitigating-your-exposure.html


When You Need To Run Remote Desktop Service On Your Server For Example : Microsoft Windows Server 2019 , With Valid Ip Address (Without comment of network confugration and Routing Role depend on your network Device (Microtik Or Cisco) You had To Open port 3389 for Remote Desktop Service , its Useless to change Remote Desktop Service Port ,The related RDP attack tools can recognition the port .and confugration Windows for open specefic port ....
so , 

After that You Can Watch Windows Remote Desktop Logins Try [failure Login / success Login] just Simply open Windows Event Viewer

To access the Event Viewer in Windows 8.1, Windows 10, and Server 2012 R2:

Right click on the Start button and select Control Panel > System & Security and double-click Administrative tools
Double-click Event Viewer
Select the type of logs that you wish to review (ex: Application, System , Security ...)

in Security Section

Error Number 4625 :
An account failed to log on.

Subject:
   Security ID:  NULL SID
   Account Name:  -
   Account Domain:  -
   Logon ID:  0x0
Logon Type:  3
Account For Which Logon Failed:
   Security ID:  NULL SID
   Account Name:  asdf
   Account Domain: 
Failure Information:
   Failure Reason:  Unknown user name or bad password.
   Status:   0xc000006d
   Sub Status:  0xc0000064
Process Information:
   Caller Process ID: 0x0
   Caller Process Name: -
Network Information:
   Workstation Name: WIN-R9H529RIO4Y
   Source Network Address: 10.42.42.201
   Source Port:  53176
Detailed Authentication Information:
      Logon Process:  NtLmSsp
   Authentication Package: NTLM
   Transited Services: -
   Package Name (NTLM only): -
   Key Length:  0

This event is generated when a logon request fails. It is generated on the computer where access was attempted.

When RDP Attack Tools Switch To your Server ip Address , Continuesly Send login autication token.



solutions : 

1- Using Hardware FireWall
2-Some Others ways....
3-Using PowerShell Script


To Use this Scrpit You Had To Add 2 firewall rule (inbound Rules , Outbound Rules)UDP Port And Block Connection on Public network with "Block RDP Attackers" 
### Variables ###
# The name of the firewall rule in Windows Firewall
$firewallRuleName = "Block RDP Attackers"

# IPs that will not be blacklisted. i.e. your home IP if you are using Dyndns or any other static IP
$whiteList = @(
   [System.Net.Dns]::GetHostAddresses("myhome.dyndns.org").IPAddressToString, #Example for DNS entry
   "89.20.58.68" #Example for IP
   )


### Script ###
Write-Host "Running at $(Get-Date)"
$regExIp = "\d\d?\d?.\d\d?\d?.\d\d?\d?.\d\d?\d?"

# Get the current Eventlogs with the 140 event
$currentAttackers = Get-Winevent Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational | Where-Object {$_.Id -eq 140} | Select Message -ExpandProperty Message

# If there is no response, there are no attacks
if ($currentAttackers -eq $null) {
   Write-Host "No current attackers"
   return
}

# Get each attackermessage and filter the IP from it using the regex above
for ($i = 0; $i -lt $currentAttackers.Count; $i++) {
   if ($currentAttackers[$i] -match $regExIp){
      $currentAttackers[$i] = $Matches[0]
   } 
}

# Get the already known attackers from the firewall rule
$knownAttackers = (Get-NetFirewallRule -DisplayName $firewallRuleName | Get-NetFirewallAddressFilter).RemoteAddress
if ($knownAttackers -eq $null){
   $knownAttackers = @()
}
$knownAttackers = $knownAttackers | Sort-Object -Unique

# Check each logged attacker and check if it is already known
foreach($newAttacker in $currentAttackers) {
   if ($knownAttackers.Contains($newAttacker)) { #If it is known, don't do anything
      continue
   }
   elseif ($whiteList -contains $newAttacker) { #If it is whitelisted, don't do anything
      Write-Host "$newAttacker is dynamically whitelisted"
      continue
   }
   else{ #otherwise it is a new attacker and add it to the blacklist
      $knownAttackers += $newAttacker
      Write-Host "Added $newAttacker"
   }
}

# remove dublicates (should not be there, but anyway...)
$knownAttackers = $knownAttackers | Sort-Object -Unique
Write-Host "$($knownAttackers.Count) IPs on blacklist"

# Setting Firwall rules with all known and all new attackers
Set-NetFirewallRule -DisplayName $firewallRuleName -RemoteAddress $knownAttackers
Write-Host ""

<!---
mehdigharibi/mehdigharibi is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->

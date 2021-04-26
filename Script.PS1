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
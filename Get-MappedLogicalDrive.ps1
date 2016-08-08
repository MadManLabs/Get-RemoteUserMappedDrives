#
# Get-RemoteUserMappedDrives.ps1
#

# Using active directory module to find user account SID
Import-Module ActiveDirectory

Function Get-RemoteUserMappedDrive
{
	PARAM (
		[string]$ComputerName,

		[string]$UserName
	)

	# The SID will be used to access the HKEY_USERS hive
	$SID = Get-ADUser -Identity $username | Select -ExpandProperty SID | Select -ExpandProperty Value

	# Command to execute on remote computer
	$Command = "Get-ChildItem Registry::HKEY_USERS\$SID\Network -recurse"

	# Creating a script block so that the $Command variable won't be $null
	$ScriptBlock = [scriptblock]::Create($Command)

	# Establish a new powershell session with remote $ComputerName
	$Session = New-PSSession -ComputerName $ComputerName
	
	# Execute command on remote system and save output to $LogicalDrives
	$LogicalDrives = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock

	# Loop through and find the mapped drive's name and pah
	$LogicalDrives | ForEach-Object { Get-ItemProperty $_.pspath | Select PSChildName, RemotePath }
	Exit-PSSession
}

# Remote ComputerName and UserName for input
$ComputerName = 'MyComputer01'
$UserName = 'User01'

# Call Function
Get-RemoteUserMappedDrive -ComputerName $ComputerName -UserName $UserName
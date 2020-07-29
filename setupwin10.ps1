#this script should be run after initial VM install on Virtual Box







#DISABLE ALL updates to stop messing things:- 

# set the Windows Update service to "disabled"
sc.exe config wuauserv start=disabled

# display the status of the service
sc.exe query wuauserv

# stop the service, in case it is running
sc.exe stop wuauserv

# display the status again, because we're paranoid
sc.exe query wuauserv

# double check it's REALLY disabled - Start value should be 0x4
REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start 






# script to delete all local user accounts 
Get-CimInstance -ClassName win32_group -Filter "name = 'administrators'" | 
Get-CimAssociatedInstance -Association win32_groupuser |
Where-Object { $_.SID -notlike "*-500" } | 
Where-Object { 
    # Filter out accounts that are used for local services
    $_.Name -notin { 
        # An array of the names for the local computer (domainpart always ".")
        Get-WmiObject -Class Win32_Service | 
        Select-Object -ExpandProperty startname -Unique | 
        Where-Object { $_ -like ".\*" } |
        ForEach-Object { Split-Path -Path $_ -Leaf }
    } 
} |
ForEach-Object {
    ([ADSI]"WinNT://.").delete("user",$_.Name)
}






#part of script to download nessesary files and setup a user with random creds

$DownPath =  $env:UserName

cd 
cd C:\Users\$DownPath\Downloads

wget https://raw.githubusercontent.com/AchintyaVatsraj/setup/master/users.txt -OutFile user.txt
wget https://raw.githubusercontent.com/AchintyaVatsraj/setup/master/pass.txt -OutFile pass.txt


$username = Get-Random -InputObject (get-content .\users.txt)
$password = Get-Random -InputObject (get-content .\pass.txt)

cmd.exe /c  "net user $username $password /add"
cmd.exe /c  "net localgroup administrators $username /add"

cmd.exe /c  "shutdown.exe /r /t 10"






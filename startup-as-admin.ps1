# Run the following commands in an Administrator powershell prompt. 
# Be sure to specify the correct path to your desktop_switcher.ahk file. 

$taskName = "SuperKeyboard"  

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {  
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false  
    Write-Host "Task '$taskName' has been unregistered."  
} else {  
    # Write-Host "Task '$taskName' does not exist."  
}
$A = New-ScheduledTaskAction -Execute "$PSScriptRoot\SuperKeyboard.exe"
$T = New-ScheduledTaskTrigger -AtLogon
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask SuperKeyboard -InputObject $D
Write-Host "Task '$taskName' has been registered."  
Start-ScheduledTask SuperKeyboard 
Write-Host "Task '$taskName' has started."  


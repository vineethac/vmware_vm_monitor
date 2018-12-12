# Module Name  : VMware VM Resource Monitor
# Script Name  : vm_monitor.ps1
# Author       : Vineeth A.C.
# Version      : 0.1
# Last Modified: 12/12/2018 (ddMMyyyy)

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$vcenter
)

Begin {
    #Ignore invalid certificate
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Verbose

    try {
        #Connect to VCSA
        Connect-VIServer -Server $vcenter
    }
    catch {
        Write-Host "Incorrect vCenter creds!"
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    #Collect list of vm names to monitor
    if (-not (test-path -path .\vm_list.txt)) {
        Disconnect-VIServer $vcenter -Confirm:$false
        Write-Error 'The file vm_list.txt does not exist!' -ErrorAction Stop
    }
    else {
        $list = Get-Content .\vm_list.txt
    } 
}
Process {
#Function to collect datastore performance stats
    Function node_perf () {

        $stat_array =@()
        
        foreach($host_name in $list) {

            $cpu_usage = Get-Stat -Entity $host_name -Stat cpu.usage.average -MaxSamples 1 -Realtime
            $cpu_ready = Get-Stat -Entity $host_name -Stat cpu.ready.summation -MaxSamples 1 -Realtime | Sort-Object Instance
            $cpu_costop = Get-Stat -Entity $host_name -Stat cpu.costop.summation -MaxSamples 1 -Realtime | Sort-Object Instance

            $mem_usage = Get-Stat -Entity $host_name -Stat mem.usage.average -MaxSamples 1 -Realtime
            $mem_active = Get-Stat -Entity $host_name -Stat mem.active.average -MaxSamples 1 -Realtime
            $mem_consumed = Get-Stat -Entity $host_name -Stat mem.consumed.average -MaxSamples 1 -Realtime
            $mem_swapin = Get-Stat -Entity $host_name -Stat mem.swapin.average -MaxSamples 1 -Realtime
            $mem_swapout = Get-Stat -Entity $host_name -Stat mem.swapout.average -MaxSamples 1 -Realtime
            
            $stat_object = New-Object System.Object
            
            $stat_object | Add-Member -Type NoteProperty -Name Name -Value "$host_name"
                
            $stat_object | Add-Member -Type NoteProperty -Name CPUusage[%] -Value "$($cpu_usage.Value)"
            $stat_object | Add-Member -Type NoteProperty -Name CPUready[%] -Value "$($cpu_ready.Value | ForEach-Object { $PSitem/200 })"
            $stat_object | Add-Member -Type NoteProperty -Name CPUco-stop[%] -Value "$($cpu_costop.Value | ForEach-Object { $PSitem/200 })"
                
            $stat_object | Add-Member -Type NoteProperty -Name MemoryUsage[%] -Value "$($mem_usage.Value)"
            $stat_object | Add-Member -Type NoteProperty -Name MemoryActive[KB] -Value "$($mem_active.Value)"
            $stat_object | Add-Member -Type NoteProperty -Name MemoryConsumed[KB] -Value "$($mem_consumed.Value)"
            $stat_object | Add-Member -Type NoteProperty -Name TotalMemorySwapIn[KB] -Value "$($mem_swapin.Value)"
            $stat_object | Add-Member -Type NoteProperty -Name TotalMemorySwapOut[KB] -Value "$($mem_swapout.Value)"
        
            $stat_array += $stat_object
        }
        return ($stat_array)
    }
}

End {
    try {
        while ($true) { 
            $result = node_perf
            Clear-Host 
            Write-Host "VM resource monitoring" -ForegroundColor Green
            $result
            Write-Host "Hit ctrl+c to stop monitoring!" -ForegroundColor Cyan
            Start-Sleep 2
        }
    }
    finally {
        Write-Host "Disconnecting! `n"
        Disconnect-VIServer $vcenter -Confirm
    }
} 


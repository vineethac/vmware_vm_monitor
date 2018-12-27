# Overview
Real-time resource usage monitoring of a list of virtual machines hosted on VMware ESXi clusters using PowerShell. The script uses VMware PowerCLI to 
get CPU and Memory usage details. Output format is given in the sample screenshot below and gets refreshed automatically every few seconds.

# How to use?
PS> .\vm_monitor.ps1 -vcenter [vcenter IP]

# Sample screenshot of output
![image](https://user-images.githubusercontent.com/30316226/49858268-16057180-fdba-11e8-8424-72c15ed2e79b.png)

# Notes
-VMware guidance: CPU Ready time and Co-Stop values per core greater than 5% and 3% respectievely could  be a performance concern. <br />
-"vm_list.txt" should contain the list of VM names to be monitored and should be present in the same directory where this PS script is saved. <br /> 

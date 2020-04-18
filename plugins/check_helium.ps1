# Check Helium logs
# Bruker helium log format: Thu May 23 04:15:00 2019 : helium level =  74 %, field =  7308.9
# Topspin writes to log every 24 hours
# Normal log path C:\Bruker\Diskless\prog\logfile\heilumlog

param([String]$logpath,$warning,$critical) 

# Parameters
$outputStringPerf = $null
$logpath = "C:\Bruker\Diskless\prog\logfiles\heliumlog"
$warning = "60"
$critical = "50"

# Performace data regex
$regexHelium = '(?<=helium level =\s+)([-.0-9]+)(?=)'
$regexNitrogen = '(?<=nitrogen level =\s+)([-.0-9]+)(?=)'
$regexField = '(?<=field =\s+)([-.0-9]+)(?=)'

<# Get Performace data #>

# Return last log entry
$lastLog = Get-Content -Path $logpath  | Select-Object -Last 1

# Return Helium
$heliumValue = Select-String  -InputObject $lastLog -Pattern $regexHelium | %{ $_.Matches } | %{ $_.Value }

# Return Nitrogen 
$nitrogenValue = Select-String  -InputObject $lastLog -Pattern $regexNitrogen | %{ $_.Matches } | %{ $_.Value }

# Return field 
$fieldValue = Select-String  -InputObject $lastLog -Pattern $regexField | %{ $_.Matches } | %{ $_.Value }


<# Build performance data string #>

if ($heliumValue -ne $null) { # Check for error state

	$outputStringPerf = $outputStringPerf + "helium=" + $heliumValue + "%;$warning%;$critical%;0%;100% "
 
	if ($nitrogenValue -ne $null) {
	
		$outputStringPerf = $outputStringPerf + "nitrogen=" + $nitrogenValue + "%;$warning%;$critical%;0%;100% "
	}
	
	if ($fieldValue -ne $null) {

		$outputStringPerf = $outputStringPerf + "field=" + $fieldValue + " "
	}
	
} else {
	# Exit with Unknown state
	Write-Host Unknown
	exit (3)
}


<# Check helium levels #>

# Parse arguments to double
$heliumValueDouble = [double]::Parse($heliumValue)
$warningDouble  = [double]::Parse($warning)
$cirticalDouble  = [double]::Parse($critical)

# Check helium
if ($heliumValueDouble -lt $cirticalDouble) { # Critical
	
	Write-Host "CRITICAL: Helium Level =" $heliumValue"%" "|" $outputStringPerf
	exit 2

} elseif ($heliumValueDouble -lt $warningDouble) { # Warning 

	Write-Host "WARNING: Helium Level =" $heliumValue"%" "|" $outputStringPerf
	exit 1

} else { # OK 

	Write-Host "OK: Helium Level =" $heliumValue"%" "|" $outputStringPerf
	exit 0
}

param([String]$installer,[String]$allowedhosts, [String]$build, [switch]$plugins) 

# Parameters
$nsclientPath = "C:\Program Files\NSClient++"
$configPath = "$nsclientPath\conf"
$pluginPath = "$nsclientPath\scripts"
$service = 'nscp'
$build32 = "bin\NSCP-0.5.2.35-Win32.msi"
$build64 = "bin\NSCP-0.5.2.35-x64.msi"

# Install NSClient base
if ($build -eq 'x64') {

	msiexec /q /I $build64

} elseif ($build -eq 'x32') {

	msiexec /q /I $build32 

} else {
	Write-Host 'Exiting, select build x64 or x32'
	exit 0
}

# Stop NSClient Service
Start-Sleep -s 10


if (Get-Service $service -ErrorAction SilentlyContinue) {

    if ((Get-Service $service).Status -eq 'Running') {

        Stop-Service $service
        Write-Host "Stopping $service"

    } else {

        Write-Host "$service found, but it is not running"

    }

} else {

    Write-Host "$serviceName not found"
}


# Create custom monitroing directories

$isMonioringPath = Test-Path -Path $configPath
if (!$isMonioringPath)  {

	New-Item -Path $configPath -ItemType Directory 
	Write-Host "Created conf directory"
}

# Create custom monitroing directories
$isPluginPath = Test-Path -Path $pluginPath
if (!$isPluginPath)  {

	New-Item -Path $pluginPath -ItemType Directory
	Write-Host "Created scripts directory"
}


# Copy NSClient boot.ini
Copy-Item -Path .\conf\boot.ini -Destination $nsclientPath\boot.ini

# Copy NSClient nsclient.ini
Copy-Item -Path .\conf\nsclient.ini -Destination $configPath\nsclient.ini

# Copy plugins
if ($plugins) {
Copy-Item -Path .\plugins\* -Destination $pluginPath\
}


<# Remove perrmisisons of NSClient conf #>

# Disable inheritance and copies the ACEs 
icacls $configPath /inheritance:d
# Remove Users
icacls $configPath /remove Users

# Start NSClient Service
Write-Host "Starting $service"
Start-Service nscp



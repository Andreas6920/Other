function upload {
     
    param (
    [Parameter(Mandatory=$true)]
    [string]$File,
    [Parameter(Mandatory=$false)]
    [switch]$Encrypt,
    [Parameter(Mandatory=$false)]
    [switch]$Randompassword)
    
    
    # Prepare system
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main"
    If(!(Get-Item $RegistryPath | ? Property -EQ "DisableFirstRunCustomize")){Set-ItemProperty -Path  $RegistryPath -Name "DisableFirstRunCustomize" -Value 1}
    
    # Variables
    $Fullname = ((get-item $file).FullName)
    $Basename = ((get-item $file).BaseName)
    $Basename_zip = $Basename + ".zip"
    $destination = Join-Path -Path $env:tmp -Childpath $Basename_zip
    if((Get-Item $file) -is [System.IO.DirectoryInfo]){$Thisisafolder = $True}

    # If compression is needed
    if ($Thisisafolder -or $Encrypt){
        # find or install 7-zip
        do{$7zip32bit = "C:\Program Files (x86)\7-Zip\7z.exe"
        $7zip64bit = "C:\Program Files\7-Zip\7z.exe"
        if (Test-Path $7zip64bit) { $process = $7zip64bit }
        elseif (Test-Path $7zip32bit) { $process= $7zip32bit }
        else { $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
        $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
        Invoke-WebRequest $dlurl -OutFile $installerPath
        Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
        Remove-Item $installerPath}}
        while ($null -eq $process)

        # Set default compression parameters for 7-zip
        $Command = "a $destination $Fullname" 
    
        # If encryption i chosen - create a password
        if($Encrypt){
        if ($encrypt){
        # Auto generate random password, 24 characters
        if($randompassword){[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
        $password = [System.Web.Security.Membership]::GeneratePassword(24,1);}
        # Set password from commandline
        else{$password = Read-Host "    - Enter Password"}
        Write-host "    - Encrypting with AES256..."}
        # Encrypt filecompression with chosen password
        $Command = "a $destination $Fullname -p$password"}   
        
        # Start compression
        Start-Process $process -ArgumentList $command -Wait;}
        
    # If compression is not needed - just point to the file and start upload
    else{$destination = $FullName}

    # Upload
    $f = Get-Item $destination
    Write-host "    - Uploading.."
    $output = (Invoke-WebRequest -Method PUT -InFile $f.FullName -Uri https://transfer.sh/$($f.Name)).Content
    $test = "iex ((New-Object System.Net.WebClient).DownloadString("+"'"+$output+"'))"
    if ($file -match ".ps1"){$output2 = $test}
    write-host "    - Upload complete:"
    write-host "`nLink: " -NoNewline; write-host $Output -f yellow
    if($encrypt){write-host "Password: $password"}
    if ($file -match ".ps1"){write-host "here's your execution script: " -NoNewline; write-host $Output2 -f yellow}
    $date = (get-date).AddDays(14); $date = get-date $date -uformat %d/%m/%Y;
    write-host "Link expiry: 14 days ($date)`n"

    # Auto-delete file if a temporary file has been created
    if ($Thisisafolder -or $Encrypt){Start-Sleep -Seconds 3
    Remove-Item $destination -Force -ErrorAction SilentlyContinue}
}
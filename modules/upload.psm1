function upload {
     
    param (
    [Parameter(Mandatory=$true)]
    [string]$File,
    [Parameter(Mandatory=$false)]
    [switch]$Encrypt,
    [Parameter(Mandatory=$false)]
    [switch]$Randompassword)
       
        # Disable Explorer first run
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
        Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1
    
        # Find 7zip or install it
        do{
            $7zip32bit = "C:\Program Files (x86)\7-Zip\7z.exe"
            $7zip64bit = "C:\Program Files\7-Zip\7z.exe"
            if (Test-Path $7zip64bit) { $process = $7zip64bit }
            elseif (Test-Path $7zip32bit) { $process= $7zip32bit }
            else { $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
            $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
            Invoke-WebRequest $dlurl -OutFile $installerPath
            Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
            Remove-Item $installerPath}}
        while ($null -eq $process)

        
        # Default parameters
            Write-host "`nStarting Module:"
            $f = Get-Item $file;
            #$process = "$env:ProgramFiles\7-Zip\7z.exe"
            $src = $f.FullName
            $dst = "$env:TMP\"+$f.BaseName+".zip"
            $command = "a $dst $src"


       #if src is directory, add compression parameter to recursive
           if((Get-Item $file) -is [System.IO.DirectoryInfo]){
           $command = $command.Replace("^a","a -r")}


       #if ecryption required, set password, rename dst file, and add password parameter
           if ($encrypt){
               
               # Set password
               if($randompassword){
                   [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
                   $password = [System.Web.Security.Membership]::GeneratePassword(24,1);}
               else{$password = Read-Host "Enter Password"}
               Write-host "..setting password"

               # Rename dst file
               $dstenc = $dst.Replace(".zip","_encrypted.zip")
               $command = $command.Replace("$dst","$dstenc")
               

               # Add password parameter
               $command = $command.Replace("$src","$src -p$password")}
               

       # start compress
       Write-host "..compressing"
       Start-Process $process -ArgumentList $command -Wait;
       
       # Upload
       if ($encrypt){$dst = $dstenc}
       $f = Get-Item $dst
       Write-host "..uploading"
       $output = (Invoke-WebRequest -Method PUT -InFile $f.FullName -Uri https://transfer.sh/$($f.Name)).Content
       $test = "iex ((New-Object System.Net.WebClient).DownloadString("+"'"+$output+"'))"
       if ($file -match ".ps1"){$output2 = $test}
       write-host "..upload complete!"
       write-host "`nLink: " -NoNewline; write-host $Output -f yellow
       if($encrypt){write-host "Password: $password"}
       if ($file -match ".ps1"){write-host "here's your execution script: " -NoNewline; write-host $Output2 -f yellow}
       write-host "Link expiry: 14 days`n"
       
       #clean-up
       remove-item $dst -Force -ErrorAction SilentlyContinue 
       
       }


      

 

    
    

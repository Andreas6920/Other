function upload {
     
    param (
    [Parameter(Mandatory=$true)]
    [string]$File,
    [Parameter(Mandatory=$false)]
    [switch]$Encrypt,
    [Parameter(Mandatory=$false)]
    [switch]$Randompassword)
       
       
       #Default parameters
       Write-host "`nStarting Module:"
       $f = Get-Item $file;
       $process = "$env:ProgramFiles\7-Zip\7z.exe"
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
               $dst1 = $dst.Replace(".zip","_encrypted.zip")
               $command = $command.Replace("$dst","$dst1")
               

               # Add password parameter
               $command = $command.Replace("$src","$src -p$password")
               
               
               }
               

       # start compress
       Write-host "..compressing"
       Start-Process $process -ArgumentList $command -Wait; start-sleep -s 10
       
       
       # Upload
       
       if ($encrypt){$dst = $dst1}
       $f = Get-Item $dst
       Write-host "..uploading"
       $output = (Invoke-WebRequest -Method PUT -InFile $f.FullName -Uri https://transfer.sh/$($f.Name)).Content
       $test = "iex ((New-Object System.Net.WebClient).DownloadString("+"'"+$output+"'))"
       if ($file -match ".ps1"){$output2 = $test}
       write-host "..upload complete!"
       write-host "`nLink: " -NoNewline; write-host $Output -f yellow
       if($encrypt){write-host "Password: $password"}
       if ($file -match ".ps1"){write-host "here's your execution script: " -NoNewline; write-host $Output2 -f yellow}
       write-host "Link expiry: 14 days"
       #write-host ""
       
       #clean-up
       remove-item $dst -Force -ErrorAction SilentlyContinue 
       
       }


      

 

    
    

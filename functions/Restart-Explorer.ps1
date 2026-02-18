Function Restart-Explorer {
            <# When explorer restarts with the regular stop-process function, the active PowerShell loses focus,
            which means you'll have to click on the window in order to enter your input. here's the hotfix. #>
            if(Get-Process -Name "Explorer" -ErrorAction SilentlyContinue){
            Stop-Process -Name "Explorer" -Force -ErrorAction SilentlyContinue | Out-Null
            Start-Sleep -Seconds 2
            if(!(Get-Process -Name Explorer)){Start-Process Explorer -ErrorAction SilentlyContinue}}
            $windowname = $Host.UI.RawUI.WindowTitle
            Add-Type -AssemblyName Microsoft.VisualBasic
            [Microsoft.VisualBasic.Interaction]::AppActivate($windowname)}
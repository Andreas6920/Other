
# Delete files

  # Configuration
    $ErrorActionPreference = 'SilentlyContinue'
    $userRoot = "C:\Users\$env:USERNAME"
    $DefaultUserFolders = @(
        'documents','my documents','dokumenter','3d objects','3d-objekter','contacts','kontakter',
        'desktop','skrivebord','downloads','overførsler','overforsler','favorites','favoritter',
        'links','music','musik','pictures','billeder','saved games','gemte spil',
        'searches','søgninger','soegninger','videos','videoer')
    $DefaultSystemFolders = @(
        'appdata','application data','cookies','local settings','lokale indstillinger',
        'start menu','menuen start','printers','printere','andre computere',
        'sendto','recent','templates','nethood','printhood')
    # Set common case for identical comparison
    $UserAllow  = $DefaultUserFolders   | ForEach-Object { $_.ToLowerInvariant() }
    $SystemKeep = $DefaultSystemFolders | ForEach-Object { $_.ToLowerInvariant() }

# Emptying windows default user folders
    Write-Host "  - Deleting personal files:" -ForegroundColor Yellow

    Get-ChildItem $userRoot -Directory -Force | ForEach-Object {
        $name = $_.Name.ToLowerInvariant()
        if ($UserAllow -contains $name -and $SystemKeep -notcontains $name) {
        Get-ChildItem $_.FullName -Force | ForEach-Object {Write-Host "`t  $($_.FullName)"; Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}}}

# Delete personal folders that aren't system folders
    Write-Host "  - Deleting personal folders:" -ForegroundColor Yellow
    Get-ChildItem $userRoot -Force | ForEach-Object {
        $name = $_.Name.ToLowerInvariant()
        if ($_.PSIsContainer) {
            if (
                ($UserAllow -notcontains $name) -and
                ($SystemKeep -notcontains $name)) {
                Write-Host "`t  $($_.FullName)"
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}}
        else {  Write-Host "`t  $($_.FullName)"
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue}}


# Delete logs

    # Configuration
        $DownloadPage   =   'https://www.bleachbit.org/download/windows'
        $TempPath       =   [System.IO.Path]::GetTempPath()
        $DesktopPath    =   [Environment]::GetFolderPath('Desktop')
        $LogsWindows    =   @('system.clipboard', 'system.custom', 'system.logs', 'system.memory_dump', 'system.muicache','system.prefetch', 'system.recycle_bin', 'system.tmp', 'deepscan.backup', 'deepscan.ds_store', 'deepscan.thumbs_db', 'deepscan.tmp', 'windows_explorer.mru', 'windows_explorer.recent_documents', 'windows_explorer.run', 'windows_explorer.search_history', 'windows_explorer.shellbags', 'windows_explorer.thumbnails',)
        $LogsChrome     =   @('google_chrome.cache', 'google_chrome.cookies', 'google_chrome.dom', 'google_chrome.form_history', 'google_chrome.history', 'google_chrome.passwords', 'google_chrome.search_engines', 'google_chrome.session', 'google_chrome.site_preferences', 'google_chrome.sync', 'google_chrome.vacuum', 'google_toolbar.search_history')
        $LogsEdge       =   @('microsoft_edge.cache', 'microsoft_edge.cookies', 'microsoft_edge.dom', 'microsoft_edge.form_history', 'microsoft_edge.history', 'microsoft_edge.passwords', 'microsoft_edge.search_engines', 'microsoft_edge.session', 'microsoft_edge.site_preferences', 'microsoft_edge.sync', 'microsoft_edge.vacuum',)
        $LogsIExplorer  =   @('internet_explorer.cache', 'internet_explorer.cookies','internet_explorer.downloads', 'internet_explorer.forms', 'internet_explorer.history','internet_explorer.logs',)
        $LogsBrave      =   @('brave.cache', 'brave.cookies', 'brave.dom', 'brave.form_history', 'brave.history', 'brave.passwords', 'brave.search_engines','brave.session', 'brave.site_preferences', 'brave.sync', 'brave.vacuum')           
        $LogsFirefox    =   @('firefox.backup', 'firefox.cache', 'firefox.cookies', 'firefox.crash_reports', 'firefox.dom', 'firefox.forms', 'firefox.passwords', 'firefox.session_restore', 'firefox.site_preferences', 'firefox.url_history', 'firefox.vacuum')
        $LogsLibreWolf  =   @('libreoffice.history', 'librewolf.backup', 'librewolf.cache', 'librewolf.cookies', 'librewolf.crash_reports', 'librewolf.dom', 'librewolf.forms', 'librewolf.passwords', 'librewolf.session_restore', 'librewolf.site_preferences', 'librewolf.url_history', 'librewolf.vacuum')
        
    
        'adobe_reader.cache', 'adobe_reader.mru', 'adobe_reader.tmp', 
    
    
    'microsoft_office.debug_logs',
    'microsoft_office.mru',
    'openofficeorg.cache',
    'openofficeorg.recent_documents',
    'opera.cache',
    'opera.cookies',
    'opera.dom',
    'opera.form_history',
    'opera.history',
    'opera.passwords',
    'opera.session',
    'opera.site_preferences',
    'opera.vacuum',
    'paint.mru',
    'realplayer.cookies',
    'realplayer.history',
    'realplayer.logs',
    'safari.cache',
    'safari.cookies',
    'safari.history',
    'safari.vacuum',
    'screenlets.logs',
    'skype.chat_logs',
    'skype.installers',
    'slack.cache',
    'slack.cookies',
    'slack.history',
    'slack.vacuum',
    'teamviewer.logs',
    'teamviewer.mru',
    'windows_media_player.cache',
    'windows_media_player.mru',
    'winrar.history',
    'winrar.temp',
    'winzip.mru',
    'wordpad.mru',
    'zoom.cache',
    'zoom.logs',
    'zoom.recordings',
    'system.free_disk_space'

        $ErrorActionPreference = 'Continue'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


    # Grab link from official website that includes portable.zip
        $Html = Invoke-WebRequest -Uri $DownloadPage -UseBasicParsing
        $FileUrl = ($Html.Links | Where-Object { $_.href -match 'portable\.zip$' }).href
        $FileUrl= $FileUrl.Replace('/download/file/t?file=','https://download.bleachbit.org/')

    # Download to temp
        $zipFile = Join-Path $TempPath ([System.IO.Path]::GetFileName($FileUrl))
        Invoke-WebRequest -Uri $FileUrl -OutFile $zipFile

    # Extract folder to desktop
        $extractFolder = $DesktopPath
        Expand-Archive -LiteralPath $zipFile -DestinationPath $extractFolder -Force

    # Find and execute rekursivt og eksekver
        $exe = (Get-ChildItem -Path $extractFolder -Filter 'bleachbit_console.exe' -Recurse | Select-Object -First 1).FullName
        #& $exe --clean system.logs




    foreach ($c in $Cleaners) {

        Write-Host "Cleaning Program: $c" -ForegroundColor Yellow
        & $exe --clean $c 2>&1 | ForEach-Object { "$c`t$_" }
    }

    Remove-Item $zipFile -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $extractFolder -Recurse -Force -ErrorAction SilentlyContinue
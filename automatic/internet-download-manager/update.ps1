function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri 'http://internetdownloadmanager.com/download.html'
    $fullUrl = $download_page.links |
               Where-Object href -Match '.exe$' |
               Select-Object -First 1 -ExpandProperty href
    $url = $fullUrl -split '\?' | Select-Object -First 1
    $version = ($url -split 'idman' | Select-Object -Last 1).
               Replace('.exe', '').
               Replace('build', '.').
               Insert(1, '.')
    return @{
        Version = $version;
        URL32 = $url;
        ChecksumType32 = 'MD5'
    }
}

function global:au_SearchReplace {
    @{
        "tools\chocolateyInstall.ps1" = @{
            "(url\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
            "(checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

Update-Package -NoCheckChocoVersion -ChecksumFor '32'

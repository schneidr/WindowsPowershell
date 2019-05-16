param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# http://blogs.technet.com/b/jamesone/archive/2007/07/13/exploring-photographic-exif-data-using-powershell-of-course.aspx
[reflection.assembly]::loadfile( "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll") | Out-Null

function MakeString { 
    $s=""
    for ($i=0 ; $i -le $args[0].value.length; $i ++) {
        $s = $s + [char]$args[0].value[$i]
    }
    return $s
}

$files = Get-ChildItem -Path $Path
foreach ($file in $files) {
    $captureDate = ''
    if ($file.Extension -ne ".jpg") { continue }
    if ($file.Name -match "^(\d+)-(\d+)-(\d+)") { continue }
    Try {
        $exif = New-Object -TypeName system.drawing.bitmap -ArgumentList $file.FullName
        $captureDate = MakeString $exif.GetPropertyItem(36867)
	    $exif.Dispose()
        $captureDate = ($captureDate -replace ":", '-').Substring(0,19)
        $newFilename = $captureDate + " " + $file.Name.Trim()
        $file.Name + " -> " + $newFilename
        $file |Rename-Item -NewName $newFilename
    }
    Catch {
        Write-Error "No Date Taken in EXIF of $file"
    }
}
$ErrorActionPreference = "Stop"

$calendarUrl = "https://bmprss.blindbrook.org/fs/calendar-manager/events.ics?calendar_ids=4"
$calendarPath = Join-Path $PSScriptRoot "calendar.ics"
$temporaryPath = Join-Path $PSScriptRoot "calendar.ics.download"
$backupName = "calendar.ics.$([guid]::NewGuid().ToString('N')).backup"
$backupPath = Join-Path $PSScriptRoot $backupName

try {
    Invoke-WebRequest -Uri $calendarUrl -OutFile $temporaryPath -UseBasicParsing

    $calendarContent = Get-Content -Path $temporaryPath -Raw
    if ($calendarContent -notmatch "BEGIN:VCALENDAR" -or $calendarContent -notmatch "END:VCALENDAR") {
        throw "The downloaded file does not look like a valid iCalendar feed."
    }

    if (Test-Path -LiteralPath $calendarPath) {
        [System.IO.File]::Replace($temporaryPath, $calendarPath, $backupPath)
        Remove-Item -LiteralPath $backupPath
    }
    else {
        Move-Item -LiteralPath $temporaryPath -Destination $calendarPath
    }

    Write-Host "Calendar updated: $calendarPath"
}
finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath
    }
    if (Test-Path -LiteralPath $backupPath) {
        Remove-Item -LiteralPath $backupPath
    }
}

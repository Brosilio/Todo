
function Read-HostKey {
    <#
        .SYNOPSIS
        Read a single keypress from the host.
    #>

    [CmdletBinding()] param (
        # A text prompt to display.
        [Parameter()]
        [string]
        $Prompt,

        # Echo the key pressed. Default is to not echo.
        [Parameter()]
        [switch]
        $Echo,

        # Return the entire key press information and not just the [char].
        [Parameter()]
        [switch]
        $Full
    )

    if (-not [string]::IsNullOrWhitespace($Prompt)) {
        Write-Host $Prompt -NoNewline
    }

    $opt = 6
    if ($Echo) {
        $opt = 4
    }

    if ($Full) {
        $Host.UI.RawUI.ReadKey($opt)
    } else {
        $Host.UI.RawUI.ReadKey($opt).Character
    }
}


function Get-PrettyDate {
    <#
        .SYNOPSIS
        Format a date to be less bad.
    #>

    [CmdletBinding()] param (
        # The date. [string] or [DateTime].
        [Parameter(Mandatory)]
        $Date
    )

    if ($date -is [string]) {
        $date = [DateTime]::Parse($date)
    }

    $diff = [DateTime]::Now.Subtract($date)
    if ($diff -gt 0) {
        if ($diff.TotalSeconds -lt 60) {
            '{0:N1}s ago' -f $diff.TotalSeconds
        } elseif ($diff.TotalMinutes -lt 60) {
            '{0:N2}m ago' -f $diff.TotalMinutes
        } elseif ($diff.TotalHours -lt 24) {
            '{0:N2}h ago' -f $diff.TotalHours
        } else {
            '{0:N2}d ago' -f $diff.TotalDays
        }
    } else {
        $diff = $diff.Negate()
        if ($diff.TotalSeconds -lt 60) {
            'in {0:N1}s' -f $diff.TotalSeconds
        } elseif ($diff.TotalMinutes -lt 60) {
            'in {0:N2}m' -f $diff.TotalMinutes
        } elseif ($diff.TotalHours -lt 24) {
            'in {0:N2}h' -f $diff.TotalHours
        } else {
            'in {0:N2}d' -f $diff.TotalDays
        }
    }
}

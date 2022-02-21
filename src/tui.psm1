
function Read-HostKey {
    [CmdletBinding()] param (
        [Parameter()]
        [string]
        $Prompt,

        [Parameter()]
        [switch]
        $Echo,

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

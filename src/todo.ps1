##
# Imports
##
Import-Module '.\tui.psm1' -Force

##
# Helper functions
##
function Save {
    $todo | ConvertTo-Json | Set-Content '~\.pstodo' -Force
}

##
# Check if ~/.pstodo exists
##
if (-not (Test-Path '~\.pstodo')) {
	Set-Content '~\.pstodo' '[]' -Force
}

##
# Read todo items from disk
##
$todo = @()
$todo += (Get-Content '~\.pstodo' | ConvertFrom-Json)
$todo = [Collections.ArrayList]$todo

##
# Enter menu loop
##
$sel = 0
while ($true) {

    ##
    # Print title
    ##
    Clear-Host
    Write-Host "--=[ Your Todo List ($($todo.Count)) ]=--" -ForegroundColor 'Cyan'
    Write-Host ''

    ##
    # Print todo items
    ##
    for ($i = 0; $i -lt $todo.Count; $i++) {
        $_ = $todo[$i]
        $fg = if ($i -eq $sel) { 'Black' } else { 'Gray' }
        $bg = if ($i -eq $sel) { 'Gray' } else { 'Black' }
        if ($_.done) { $fg = 'Darkgray' }
        $x = switch ($_.done) { $true { 'x' } default { ' ' } }

        # convert date string back to [datetime]
#        $_.date = [datetime]::Parse($_.date)

        Write-Host "$($i + 1) [$x] " -NoNewline -ForegroundColor $fg -BackgroundColor $bg
        Write-Host $_.todo -NoNewline -ForegroundColor $fg -BackgroundColor $bg
        Write-Host " (added $(Get-PrettyDate $_.date))" -ForegroundColor 'DarkGray'
    }

    ##
    # Print keybinds
    ##
    Write-Host ''
    Write-Host '[N]ew, [D]uplicate, [Q]uit' -ForegroundColor 'Cyan'
    Write-Host '[space] toggles completion' -ForegroundColor 'Cyan'
    Write-Host '[delete] to delete an item' -ForegroundColor 'Cyan'

    ##
    # Process input
    ##
    $key = Read-HostKey -Full
    switch ($key.Character) {
        # Escape ([q]uit)
        { $_ -in 'q','' } {
            Save
            exit 0
        }

        # [N]ew item
        'n' {
            $todo.Add(@{
                done = $false
                todo = Read-Host 'Task'
                date = [DateTime]::Now.ToString()
            })
            Save
        }

        # [E]dit item
        #'e' { write-host 'edit item' }

        # [D]uplicate item
        'd' {
            $todo.Add($todo[$sel])
            Save
        }

        # [S]ort items
        #'s' { write-host 'sort items' }

        # Complete/uncomplete item
        ' ' {
            $todo[$sel].done = (-not $todo[$sel].done)
            Save
        }

        'i' {
            $todo | ConvertTo-Json | Write-Host
            Read-HostKey
        }

        # non-printables
        '' {
            switch ($key.VirtualKeyCode) {
                # Delete item (delete)
                46 {
                    if ((Read-HostKey -Prompt 'Delete item? (y/n): ') -eq 'y')  {
                        $todo.RemoveAt($sel)
                        Save
                    }

                    # Move selection back if the last item was deleted
                    if ($sel -gt $todo.Count - 1) {
                        $sel--
                    }
                }

                # Down arrow
                40 { $sel++ }

                # Up arrow
                38 { $sel-- }
            }
        }
    }

    # clamp $sel to valid range
    $sel = [math]::Max($sel, 0)
    $sel = [math]::Min($sel, $todo.Count - 1)
}

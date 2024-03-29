
#
# load (dot-source) *.PS1 files, excluding unit-test scripts (*.Tests.*), and disabled scripts (__*)
#

@("$PSScriptRoot\Public\*.ps1","$PSScriptRoot\Private\*.ps1") | Get-ChildItem | 
    Where-Object { $_.Name -like '*.ps1' -and $_.Name -notlike '__*' -and $_.Name -notlike '*.Tests*' } | 
    ForEach-Object {

        # dot-source script
        Write-Host "Loading $($_.BaseName)"
        . $_

        # export functions in the `Public` folder
        if ( (Split-Path( $_.Directory) -Leaf) -Eq 'Public' ) {
            Write-Host "Exporting $($_.BaseName)"
            Export-ModuleMember $_.BaseName
        }

    }

#
# manually export aliases specified in a PS1 file (can this be done automatically?)
#

# Export-ModuleMember -Alias gba

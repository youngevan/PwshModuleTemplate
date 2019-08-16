
Function Invoke-NewModuleManifest {
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$true,Position=1)]
        [String]$ModuleName,
        [Parameter(Mandatory=$true,Position=2)]
        [String]$Description,
        [Parameter(Mandatory=$true,Position=3)]
        [String]$Author

    )
    <#
        .NOTES
            Created by: Evan Young
        
        .DESCRIPTION
            Wrapper function to properly create a module manifest per established practices and patterns.

        .PARAMETER Path
            E.g. 'C:\dev\projects\modules\Module_Template\Module_Template.psd1'
        
        .PARAMETER ModuleName
            E.g. 'Module_Template.psm1'
        
        .PARAMETER Description
            E.g. 'Contains script functions to test new module organization.'
        
        .PARAMETER Author
            E.g. 'Evan Young'

        .EXAMPLE
            PS> Invoke-NewModuleManifest -Path 'C:\dev\projects\modules\Module_Template\Module_Template.psd1' -ModuleName 'Module_Template.psm1' -Description 'Contains script functions to test new module organization.' -Author 'Evan Young'
            
    #>

    $copyright = "(c) " + (Get-Date).Year + " " + $Author + ". All rights reserved."

    $manifest = @{
        "author" = $Author
        "CompanyName" = "MyCompanyName"
        "Copyright" = $copyright
        "Description" = $Description
        "ModuleToProcess" = $ModuleName
        "FunctionsToExport" = @("*")
        "Path" = $Path
        "ModuleVersion" = "0.0.1"
    }
    New-ModuleManifest @manifest
}

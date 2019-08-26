#requires -Version 3.0

<#
    .Description
        Builds a module for production distribution.

    .Parameter Path
        The path of the targeted module.

    .Parameter Version
        The version you're building. Cannot already exist. Use semantic Versioning 

    .Parameter CreateZip
        Switch to create a zip file for the build version you're building. This uses the Compress-Archive cmdlet which was introduced in PS v3.0

    .Parameter Overwrite
        Switch parameter used to overwrite the targeted build in the script making it easier for development.

    .Parameter PowershellTargetVersion
        Used to build a module for a specific version of Powershell in mind, currently options are:  2.0, 3.0, 4.0, 5.0, 5.1, 6.0, 7.0. 
        The current version that really changes anything or must be used for additional build tasks is for 2.0 if the module is being built
        for systems that run Powershell 2.0.

    .Example
        PS C:\dev\Module_Template\Build\> .\build.ps1 -Name 'Module_Template' -Path 'C:\dev\Module_Template\'  -Version 'v1.02' -CreateZip -Overwrite -PowershellTargetVersion 2.0

    .Example
        PS C:\dev\Module_Template\Build\> .\build.ps1 -Path 'C:\dev\Module_Template\' -Version 'v0.0.1' -CreateZip
        
#>


[CmdletBinding()]
Param(
    [parameter(Position=0,Mandatory=$true)][string]$Name,
    [parameter(Position=1,Mandatory=$true)][string]$Path,
    [parameter(Position=2,Mandatory=$true)][string]$Version,
    [switch]$CreateZip,
    [switch]$Overwrite,
    [ValidateNotNullOrEmpty()]
    [ValidateSet('2.0','3.0','4.0','5.0','5.1','6.0','7.0')]
    [String]$PowershellTargetVersion = "3.0"
)


######################################
# perform tests? after writing tests #
######################################


# targets a version number and creates a corresponding version number folder in the build folder -- error if target version already exists
$buildVersionPath = Join-Path -Path $Path -ChildPath "\Build\$Version"

If ( $Overwrite ) { If ( Test-Path $buildVersionPath ) { Remove-Item -Path $buildVersionPath -Recurse -Force } }

If ( Test-Path $buildVersionPath ) {
    Write-Error "Build Version already exists, must change your target build version."
    Return
} Else {
    Try { 
        # create version directory
        New-Item -Path $buildVersionPath -ItemType Directory | Out-Null
    }
    Catch {
        Write-Error 'Unable to create new build version folder.'
        Return 
    }
}

#################################################
# creates the files as needed (.psd1 and .psm1) #
#################################################

$buildversionrootpath = Join-Path -Path $buildversionPath -ChildPath $Name

# create module directory in the build version 
New-Item $buildversionrootpath -ItemType Directory | Out-Null

# create script module file in target build version module directory
#$ModuleFilePath =  ((Split-Path $buildversionrootPath -Leaf).ToString())
$scriptModuleFilePath = $Name +  ".psm1"
$buildVersionModuleFilePath = New-Item -Path (Join-Path -Path $buildversionrootpath -ChildPath $scriptModuleFilePath ) -ItemType File


#####################################################################
# copy content from each .ps1 file into .psm1 as separate functions #
#####################################################################
$thisScript = $MyInvocation.MyCommand.Name

$functionFiles = Get-ChildItem -Path $path -Filter *.ps1 -Recurse | Where-Object { $_.BaseName -notlike '*.tests*' -and $_.Name.ToString() -ne $thisScript }

foreach ($file in $functionFiles) {
    
    # get content from ps1
    $functionFileContent = Get-Content -Path $file.FullName

    # add newline feed to begining psm1 content
    Add-Content -Path $buildVersionModuleFilePath -Value "`r`n"

    # get content from psm1
    #$scriptModuleContent = Get-Content -Path $buildVersionModuleFilePath
    
    # append content from ps1 to existing psm1 content
    Add-Content -Path $buildVersionModuleFilePath -Value $functionFileContent

    # add newline feed to end of psm1 content
    # Add-Content -Path $buildVersionModuleFilePath -Value "`r`n"
    
    # set newly appended content to psm1 file
}


######################################################
# explicitly list exported public functions in psd1 #
######################################################

#get name of ps1 files in Public
$publicFunctions = (Get-ChildItem -Path (Join-Path -Path $path -ChildPath 'Public') -Filter *.ps1 | Where-Object { $_.BaseName -notlike '*.tests*' }).BaseName

$functionsListArray = @()

#for each filename, add to $functionsListArray
foreach ( $publicFunction in $publicFunctions ){
    $functionsListArray += $publicFunction
}


###########################################
# create the module manifest (.psd1) file #
###########################################
$moduleManifest = $name + ".psd1"
$moduleManifestPath = $buildversionrootPath + "\" + $moduleManifest
$moduleToProcess = Split-Path -Path $buildVersionModuleFilePath -Leaf
$moduleVersion = $Version.TrimStart("v")


# create module manifest file in target build version module directory
$manifest = @{
    "author" = "Evan Young"
    "CompanyName" = "My IT Request"
    "Copyright" = "(c) 2019 Evan Young. All rights reserved."
    "Description" = "Contains functions to perform tasks."
    "ModuleToProcess" = $moduleToProcess
    "Path" = $moduleManifestPath
    "ModuleVersion" = $moduleVersion
    "PowershellVersion"="2.0"
}
$createManifest = { New-ModuleManifest @manifest }
& $createManifest
# & Powershell.exe -version 2.0 -Command { New-ModuleManifest -author "Evan Young" -CompanyName "My IT Request" -Copyright "(c) 2019 Evan Young. All rights reserved." -Description "Contains script functions to test new module organization." -ModuleToProcess $moduleToProcess -Path $moduleManifestPath -ModuleVersion $moduleVersion -PowershellVersion "2.0" }
Update-ModuleManifest -Path $moduleManifestPath -FunctionsToExport $functionsListArray

# was trying to update the functions to export to be listed explicitly as an array
# $functionsListString = forEach ($function in $functionsListArray){
    # ""
# }
# $functionsToExport = "@(`r`n" + $functionsListString + "`r`n)"
# Get-Content -Path $moduleManifestPath | Where-Object { $_ -eq "FunctionsToExport = `'*`'"}


#################################
# Powershell v2.0 tasks - BEGIN #
#################################
if ( $PowershellTargetVersion -eq '2.0' ) {
    

    # update psd1
    # removing RootModule member

    # PS 2.0 doesn't like the RootModule member of the manifest
    # or maybe I'll just use PS 2.0 to create the module manifest
    $find = "RootModule = `'" + $scriptModuleFilePath + "`'"
    $replace = "ModuleToProcess = `'" + $scriptModuleFilePath + "`'`r`n#RootModule = `'" + $scriptModuleFilePath + "`'  #introduced in v3, unsupported in v2, using ModuleToProcess instead"
    # Get-Content -Path $moduleManifestPath | ForEach-Object { $_ -replace  $find, $replace }
    Set-Content -Path $moduleManifestPath -Value (Get-Content -Path $moduleManifestPath | ForEach-Object { $_ -replace  $find, $replace })


}
###############################
# Powershell v2.0 tasks - END #
###############################

###################
# create zip file #
###################
if ( $CreateZip ) {
    $zipFilePath = $buildversionrootPath + "\" + $Name + ".zip"
    Compress-Archive -Path (Join-Path -Path $buildversionrootPath -ChildPath '*') -CompressionLevel Optimal -DestinationPath $zipFilePath
}


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

    .Example
        PS C:\dev\Module_Template\Build\> .\build.ps1 -Path 'C:\dev\Module_Template\' -Version 'v0.0.1' -CreateZip

#>


[CmdletBinding()]
Param(
    [parameter(Position=1,Mandatory=$true)][string]$Path,
    [parameter(Position=2,Mandatory=$true)][string]$Version,
    [switch]$CreateZip
)


######################################
# perform tests? after writing tests #
######################################


# targets a version number and creates a corresponding version number folder in the build folder -- error if target version already exists
$buildVersionPath = Join-Path -Path $Path -ChildPath "\Build\$Version"

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

$buildversionrootpath = Join-Path -Path $buildversionPath -ChildPath (Split-Path $path -Leaf)

# create module directory in the build version 
New-Item $buildversionrootpath -ItemType Directory | Out-Null

# create script module file in target build version module directory
$ModuleFilePath =  ((Split-Path $buildversionrootPath -Leaf).ToString())
$scriptModuleFilePath = $ModuleFilePath +  ".psm1"
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
$moduleManifestPath = $buildversionrootPath + "\" + $ModuleFilePath + ".psd1"
$moduleToProcess = Split-Path -Path $buildVersionModuleFilePath -Leaf
$moduleVersion = $Version.TrimStart("v")


# create module manifest file in target build version module directory
$manifest = @{
    "author" = "Evan Young"
    "CompanyName" = "TestCompany"
    "Copyright" = "(c) 2019 Evan Young. All rights reserved."
    "Description" = "Contains script functions to test new module organization."
    "ModuleToProcess" = $moduleToProcess
    "Path" = $moduleManifestPath
    "ModuleVersion" = $moduleVersion
}
New-ModuleManifest @manifest
Update-ModuleManifest -Path $moduleManifestPath -FunctionsToExport $functionsListArray

# $functionsListString = forEach ($function in $functionsListArray){
    # ""
# }
# $functionsToExport = "@(`r`n" + $functionsListString + "`r`n)"
# Get-Content -Path $moduleManifestPath | Where-Object { $_ -eq "FunctionsToExport = `'*`'"}

###################
# create zip file #
###################
if ( $CreateZip ) {
    $zipFilePath = $buildversionrootPath + "\" + $ModuleFilePath + ".zip"
    Compress-Archive -Path (Join-Path -Path $buildversionrootPath -ChildPath '*') -CompressionLevel Optimal -DestinationPath $zipFilePath
}


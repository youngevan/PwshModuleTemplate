
Function Get-PublicFunction2 {
    [CmdletBinding()]
    param()
    Write-Host Executing... $MyInvocation.MyCommand.Name -ForegroundColor Magenta
    Write-Host "This is my public function #2."

}


Function Get-PrivateFunction {
    [CmdletBinding()]
    param()
    Write-Host Executing... $MyInvocation.MyCommand.Name -ForegroundColor Magenta
    Write-Host This is my PRIVATE function.

}

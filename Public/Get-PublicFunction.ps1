
Function Get-PublicFunction {
    [CmdletBinding()]
    param()
    Write-Host Executing... $MyInvocation.MyCommand.Name -ForegroundColor Magenta
    Write-Host This is my public function. It calls the private function.

    Get-PrivateFunction
}

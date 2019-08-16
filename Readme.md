# Powershell Module Template

### Reference: 
Inspiration from and credit to: 
- https://mikefrobbins.com/2018/08/17/powershell-script-module-design-public-private-versus-functions-internal-folders-for-functions/
- https://nickhudacin.wordpress.com/2016/04/27/powershell-tips/
- https://github.com/craibuc/PsModuleTemplate
- https://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/

Would like to get here at some point:
- https://github.com/PoshCode/ModuleBuilder

### Why?
This module organization is a best practice for a larger module with many functions.

### Development
During development, the module should be structured with each function in separate ps1
scripts within a public and private folder with tests matching the ps1 script file. 
The ps1 script for the function itself must match the name of the function.

### Production
For the production build, the script files should be removed and moved to the script 
module psm1 file. This allows for faster and smoother importing of the module as the 
module increases in size. 

### Build
Run the build.ps1 script to a new version path when you want to build a production
release build of the module. The build script moves the functions from the ps1 
script files to the script module psm1 file. Also, it will update the psd1 file to
change the list of public functions to be exported. It will target a build version
and place the module in a folder named by the version provided, it will be located 
within the builds folder.

### Tests
A note about the tests-- in their current form they aren't one for one per function
and not created yet. This is intentional as of now I am not implementing testing,
although I would like to be. This is the next step to implement testing.

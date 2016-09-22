# OpsGenie-PSAPI
Powershell implementation of the OpsGenie API

## Getting Started
### Installation
Use of the Powershell OpsGenie-PSAPI modules requires an API Key from [OpsGenie](https://www.opsgenie.com).

Download the module files (*.psm1 and *.psd1) and place them in one of the following locations:

- For specific users: `$home\Documents\WindowsPowershell\Modules\<Module Folder>\<Module Files>`
- For all users on the computer: `$EnvProgramFiles\WindowsPowerShell\Modules\<Module Folder>\<Module Files>`

These locations are part of the PSModulePath environment variable. To list the directories in that variable, use either of the following commands:

- `$Env:PSModulePath`
- `[Environment]::GetEnvironmentVariable("PSModulePath")`

### Load Module and List Available Commands
In Powershell v3+, the Module will auto-import when in one of these directories.
To load the module explicitly, run the command `Import-Module -Name OpsGenie-Alerts`. 
This must be done before you can list available commands for the module.

To list the available commands for the function, run the following command:

`Get-Command -Module OpsGenie-Alerts`

### Get Further Help
The OpsGenie-Alerts module has rich documentation of each function. To view this documentation, use the `Get-Help` cmdlet to view command documentation.

For Example: `Get-Help New-OpsGenieAlert [-detailed, -full, -examples]`
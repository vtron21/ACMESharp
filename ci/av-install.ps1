$doRdp = $false
try { $doRdp = ((wget http://acmesharp.zyborg.io/appveyor-rdp.txt).Content -eq 1) }
catch { }
if ($doRdp) {
  Write-Warning "Detected RDP access request"
  iex ((new-object net.webclient).DownloadString(
	  'https://raw.githubusercontent.com/appveyor/ci/master/scripts/enable-rdp.ps1'))
}
else {
  Write-Output "No RDP access requested"
}

nuget restore ACMESharp\ACMESharp.sln
nuget install secure-file -ExcludeVersion
secure-file\tools\secure-file -secret $env:secureInfoPassword -decrypt ACMESharp\ACMESharp-test\config\dnsInfo.json.enc
secure-file\tools\secure-file -secret $env:secureInfoPassword -decrypt ACMESharp\ACMESharp-test\config\webServerInfo.json.enc
secure-file\tools\secure-file -secret $env:secureInfoPassword -decrypt ACMESharp\ACMESharp-test\config\testProxyConfig.json.enc

& .\ACMESharp\ACMESharp.Providers-test\Config\secure-AllParamsJson.ps1 -Decrypt -Secret $env:secureInfoPassword

Write-Output "Installed Software:"
$x64items = @(Get-ChildItem "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
$x64items + @(Get-ChildItem "HKLM:SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall") `
   | ForEach-object { Get-ItemProperty Microsoft.PowerShell.Core\Registry::$_ } `
   | Sort-Object -Property DisplayName `
   | Select-Object -Property DisplayName,DisplayVersion
$x64items

Write-Output "PowerShell Versions:"
Write-Output ($PSVersionTable | ConvertTo-Json)

Write-Output "Updating to the latest PSGet module"
Write-Output "  * Mod Info BEFORE install:"
Write-Output (Get-Module PowerShellGet -ListAvailable | ConvertTo-Json)

Install-Module -Name PowerShellGet -Force

Write-Output "  * Mod Info AFTER install:"
Write-Output (Get-Module PowerShellGet -ListAvailable | ConvertTo-Json)

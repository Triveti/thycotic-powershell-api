. ./FolderManager.ps1
. ./ConfigurationManager.ps1
. ./SecretManager.ps1

# parameters
$url = "http://<THYCOTIC_URL>/SecretServer";
$username = "<USERNAME>";
$password = "<PASSWORD>";

# Initialize the classes
$foldermanager = [FolderManager]::new($url,$username,$password)
$configurationmanager = [ConfigurationManager]::new($url,$username,$password)
$secretmanager = [SecretManager]::new($url,$username,$password)

# Add single folder 'Pippo1' and its subfolder 'Pippo2'
try {
  $pippo1 = $foldermanager.AddFolder("Pippo1")
}
 catch {
    Write-Host "Exception:"
    Write-Host $_ 
 }

try {
    $pippo2 = $foldermanager.AddChildFolder("Pippo2", $pippo1)
}
 catch {
    Write-Host "Exception:"
    Write-Host $_ 
 }



# Set permissions to folder 'Pippo1'
$folderName = "Pippo1"
$groupName = "Everyone"
$folderAccessRoleName = "View"
$secretAccessRoleName = "View"

$result01 = $foldermanager.SetFolderPermissions($folderName, $groupName, $folderAccessRoleName, $secretAccessRoleName)

# Perform a complete backup of SS
$result = $configurationmanager.RunBackup()
Write-Host $result
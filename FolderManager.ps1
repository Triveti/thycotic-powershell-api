###########################################################################################################################################################
# Created By: Triveti B.V.
# https://www.triveti.com
# Date: 08/03/2021
# Description: Manage Folders and its permissions
###########################################################################################################################################################

class FolderManager 
{
 [String] $token
 [String] $uri

 # Constructor calls the method GetToken and generates the access_token internally
 FolderManager ($url, $username, $password)
 {
    $this.token = $this.GetToken($url, $username, $password)
    $this.uri = $url
 }

 # Method GetToken
 [String] GetToken ($url, $username, $password)
    {
     $creds = @{
        username = $username
        password = $password
        grant_type = "password"
     };
     $headers = $null
     try {
        $response = Invoke-RestMethod "$url/oauth2/token" -Method Post -Body $creds -Headers $headers;
        $access_token = $response.access_token;
        return $access_token; 
     }
     catch {
        $result = $_.Exception.Response.GetResponseStream();
        $reader = New-Object System.IO.StreamReader($result);
        $reader.BaseStream.Position = 0;
        $reader.DiscardBufferedData();
        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "ERROR DURING AUTHENTICATION: $($responseBody.error)"
        return $responseBody; 
     }
   }
   # This method adds a single folder
   [String] AddFolder($name){
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $headers.Add("Authorization", "Bearer " + $this.token)
      $server = $($this.uri)
      # Get Folder Stub
      $folderStub = Invoke-RestMethod -Uri $server"/api/v1/folders/stub" -Method GET -Headers $headers -ContentType "application/json"
      
      $folderStub.folderName = $name
      $folderStub.folderTypeId = 1
      $folderStub.inheritPermissions = $false
      $folderStub.inheritSecretPolicy = $false
  
      $folderArgs = $folderStub | ConvertTo-Json
  
      $folderAddResult = Invoke-RestMethod -Uri $server"/api/v1/folders" -Method POST -Body $folderArgs -Headers $headers -ContentType "application/json"
      
      if($folderAddResult.id -gt 1)
      {
         Write-Host "Add Folder Successful: " + $folderAddResult | ConvertTo-Json
      }
      else
      {
         Write-Host "ERROR: Failed to Add a folder."
      }
      return $folderAddResult.id
  }


  [String] AddChildFolder($name, $parentfolderid){
   $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
   $headers.Add("Authorization", "Bearer " + $this.token)
   $server = $($this.uri)
   # Get Folder Stub
   $folderStub = Invoke-RestMethod -Uri $server"/api/v1/folders/stub" -Method GET -Headers $headers -ContentType "application/json"
   
   $folderStub.folderName = $name
   $folderStub.folderTypeId = 1
   $folderStub.parentFolderId = $parentfolderid
   $folderStub.inheritPermissions = $false
   $folderStub.inheritSecretPolicy = $false

   $folderArgs = $folderStub | ConvertTo-Json

   $folderAddResult = Invoke-RestMethod -Uri $server"/api/v1/folders" -Method POST -Body $folderArgs -Headers $headers -ContentType "application/json"
   
   if($folderAddResult.id -gt 1)
   {
      Write-Host "Add Folder Successful: " + $folderAddResult | ConvertTo-Json
   }
   else
   {
      Write-Host "ERROR: Failed to Add a folder."
   }
   return $folderAddResult.id
}

 [String] SetFolderPermissions ($folderName, $groupName, $folderAccessRoleName, $secretAccessRoleName) {
   
   $groupId = 21
   $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
   $headers.Add("Authorization", "Bearer " + $this.token)
   $server = $($this.uri)
   
   # Get folderId from folderName
   $folderRecord = Invoke-RestMethod $server"/api/v1/folders/lookup?filter.searchText=$folderName" -Method GET -Headers $headers -ContentType "application/json"
   $folderId = $folderRecord.records.id

   if ($folderRecord.records.Count -gt 1){
      throw "Multiple folders found."
   }

   # Get groupID from groupName
   $groupRecord = Invoke-RestMethod $server"/api/v1/groups/lookup?filter.searchText=$groupName" -Method GET -Headers $headers -ContentType "application/json"
   $groupId = $groupRecord.records.id

   $folderPermissionCreateArgs = Invoke-RestMethod $server"/api/v1/folder-permissions/stub?filter.folderId=$folderId" -Method GET -Headers $headers -ContentType "application/json"
   #To give permissions to a group, populate the GroupId variable and leave UserId $null.
   $folderPermissionCreateArgs.GroupId = $groupId
   $folderPermissionCreateArgs.UserId = $null
   $folderPermissionCreateArgs.FolderAccessRoleName = $folderAccessRoleName
   $folderPermissionCreateArgs.SecretAccessRoleName = $secretAccessRoleName

   $permissionArgs = $folderPermissionCreateArgs | ConvertTo-Json

   $permissionResults = Invoke-RestMethod $server"/api/v1/folder-permissions" -Method POST -Headers $headers -Body $permissionArgs -ContentType "application/json"
   if($permissionResults.FolderId -eq $folderId)
     {
      Write-Host "Add Folder Permissions Successful"
      return $permissionResults
     }
   else
     {
      return "ERROR: Failed to Add Folder Permissions." 
   }
   #$folderPermissionId = $permissionResults.id
 }

}
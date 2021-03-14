###########################################################################################################################################################
# Created By: Triveti B.V.
# https://www.triveti.com
# Date: 08/03/2021
# Description: Manage various configurations.
###########################################################################################################################################################

class ConfigurationManager 
{
 [String] $token
 [String] $uri

 # Constructor calls the method GetToken and generates the access_token internally
 ConfigurationManager ($url, $username, $password)
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
   # This method performs a complete backup
   [String] RunBackup(){
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $headers.Add("Authorization", "Bearer " + $this.token)
      # Run Backup
      $server = $($this.uri)
      $backup = Invoke-RestMethod -Uri $server"/api/v1/configuration/backup/run-now" -Method POST -Headers $headers -ContentType "application/json"
      return "Backup executed successfully: " + $backup
  }
}
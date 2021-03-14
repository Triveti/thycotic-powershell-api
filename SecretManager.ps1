###########################################################################################################################################################
# Created By: Triveti B.V.
# https://www.triveti.com
# Date: 09/03/2021
# Description: Manage Secrets.
###########################################################################################################################################################

class SecretManager 
{
 [String] $token
 [String] $uri

 # Constructor calls the method GetToken and generates the access_token internally
 SecretManager ($url, $username, $password)
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

    ListAllSecrets(){
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $headers.Add("Authorization", "Bearer " + $this.token)
      # Get Folder Stub
      $server = $($this.uri)
      $secretresults = Invoke-RestMethod -Uri $server"/api/v1/secrets?filter.extendedFields=username" -Method GET -Headers $headers -ContentType "application/json"
      
      For ($i=0; $i -lt $secretresults.records.Count; $i++){
       Write-Host $secretresults.records[$i]
       #$id = $secretresults.records[$i].id
      }
    }

}
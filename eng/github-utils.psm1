# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

function TagFromVersion ([string]$Version) { return $Version -replace "v","Pre-Release-v" }

function CreateRelease {
  param (
    [Parameter(Mandatory=$true)] [string] $RepoUrl,
    [Parameter(Mandatory=$true)] [string] $Version,
    [Parameter(Mandatory=$true)] [string] $Token
  )
    $tag = TagFromVersion $Version

    $body = @{
      tag_name = "$tag"
      target_commitish = "main"
      name = "Pre-Release $version"
      body = ""
      draft = $false
      prerelease = $true
      generate_release_notes = $false
    } | ConvertTo-Json
  
    $headers = @{
      Accept = "application/vnd.github+json"
      Authorization = "Bearer $Token"
    }

    try {
      $result = Invoke-RestMethod -Method POST -Uri "$RepoUrl/releases" -Body $body -Headers $headers
      Write-Output ("New release created at {0}" -f $result.html_url)
      return {
        ReleaseUrl = $result.html_url
        UploadUrl = $result.upload_url
      }
    }
    catch {
      Write-Error ("ERROR: {0}" -f $_)
    }
}

Export-ModuleMember -Function CreateRelease

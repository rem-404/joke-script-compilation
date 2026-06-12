<#
Part of meme script family for job hunting analytics
It reduces the friction of sending job applications and adding it on the csvofdisappointment
#>

function New-Application {
  param (

    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Company,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Position,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]$Platform,

    [Parameter(Mandatory = $true)]
    [string]$Notes,

    [Parameter(Mandatory = $true)]
    [string]$Odds,

    [Parameter(Mandatory = $true)]
    [string]$Link,

    [string]$Skill
  )

  try {

    if (-not $skill) {
      Write-Host "[*] No manual skills provided. Invoking Skill Parser..." -ForegroundColor Yellow
      $Skill = Get-SkillParse
    }

    if (-not $Skill) {
      throw "Parser returned no skills. Aborting database entry."
    }

    $NewRow = [PSCustomObject]@{
      Date            = (Get-Date -Format 'M/d/yyyy')
      Company         = $Company
      Position        = $Position
      Platform        = $Platform
      Status          = 'Uncertain'
      Notes           = $Notes
      Odds            = $Odds
      UserName        = ''
      Password        = ''
      Link            = $Link
      AutomationStamp = ''
      Skills          = $Skill
    }

    
    $NewRow | Export-Csv -Path '.\CsvOfDisappointment.csv' -Append -NoTypeInformation
    
    # Write-Host "Application to $Company in a $Position position has been added" -ForegroundColor Green

    # Import-Csv .\CsvOfDisappointment.csv | Select-Object -last 1

    Write-Host "`n[+] ENTRY VERIFIED AND COMMITTED TO DATABASE:" -ForegroundColor Green
    $NewRow | Format-List Date, Company, Position, Platform, Odds, Skills | Out-String | ForEach-Object {
      Write-Host "    $_" -ForegroundColor DarkCyan
    }

  }
  catch {
    Write-Warning "$($_.Exception.Message)"
  }

}

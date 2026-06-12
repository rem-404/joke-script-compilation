function Set-Status {
  param (
    [Parameter(Position = 0)]
    [string]$Name,

    [Parameter(Position = 1)]
    [ValidateSet('uncertain', 'responded', 'denied', 'ghosted', 'hired')]
    [string]$Status
  )

  try {
    $CurrentData = Import-Csv .\CsvOfDisappointment.csv
    ($CurrentData | Where-Object { $_.company -like "*$Name*" }).status = $Status
    $CurrentData | Export-Csv .\CsvOfDisappointment.csv -NoTypeInformation
    
    Write-Host "Target '$Name' successfully marked as '$Status'. Grid updated!" -ForegroundColor Green

  }
  catch {
    Write-Warning "$($_.Exception.Message)"
  }

}

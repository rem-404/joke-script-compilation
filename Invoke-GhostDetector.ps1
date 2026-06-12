<#
The script is a partner for the "Get-EmotionalDamageAnalytics" script, designed to manage and update the status of 
job applications based on their age and response status. 
It reads a CSV file containing job application data, checks for applications that have been marked as "Uncertain" 
for a specified number of days, and updates their status to "Ghosted" if they meet the criteria. The script also adds 
an automation timestamp for when the status was updated. Finally, it exports the updated data back to the CSV file.
#>

function Invoke-GhostDetector {
  [CmdletBinding()]
  param(
    [string]$CsvPath = "C:\Logs\CsvOfDisappointment.csv",
    [int]$StaleDays = 3
  )

  $applications = Import-Csv $CsvPath

  $updated = $applications | ForEach-Object {
    if ($_.Status -eq 'Uncertain' -or [string]::IsNullOrWhiteSpace($_.Status)) {
      $appliedDate = [DateTime]$_.Date
      $daysPending = ((Get-Date) - $appliedDate).Days

      if ($daysPending -ge $StaleDays) {
        $_.Status = 'Ghosted'
        $_.AutomationStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        
        Write-Verbose "Application for $($_.Company) Company - $($_.Position) Position is marked as Ghosted after $daysPending days of no response."
      }
    }
    $_
  }

  $updated | Export-Csv $CsvPath -NoTypeInformation
  Write-Host "Stale applications flagged." -ForegroundColor Yellow
}

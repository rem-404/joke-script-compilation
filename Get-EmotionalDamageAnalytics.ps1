<#
Emotional devastator v-1.3
Import-csv .\CsvOfDissapointment.csv | Get-EmotionalDamageAnalytics

CSV Format (the ones with * are required for the script to work, the rest is just for extra analytics and fun)

*Date,	Company,	Position,	Platform, *Status,	Notes,	Odds,	UserName,	Password,	Link, *AutomationStamp, *Skills
#>
function Get-EmotionalDamageAnalytics {

  [cmdletbinding()]
  param (
    [parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$Date,
    [parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$Status,

    # Testing New feature: skills column for market analysis
    [parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$Skills
    
  )

  BEGIN {

    $ErrorActionPreference = 'Stop' # Make sure any error will be caught by try/catch
    $FirstDate = $null
    $HiredCount = 0
    $InterviewCount = 0
    $DeniedCount = 0
    $ResponseCount = 0
    $UncertainCount = 0
    $GhostedCount = 0
    $MasterSkillList = @() # Dynamic list from skills column
  }


  PROCESS {

    try {
      if ($null -eq $FirstDate -and $Date) { 
        $FirstDate = [DateTime]($Date -join '') # selecting just the first string value passed into the pipe
      }

      # ======================================== #
      #              DATA GATHERING              #
      # ======================================== #
    
      foreach ($Stats in $Status) {

        if ($stats -eq 'hired') {
          Write-Host "Boom! Hired! No emonotional damage here!" -ForegroundColor Green
          $HiredCount += 1
        }
        elseif ($Stats -eq 'interviewed') { $InterviewCount += 1 }
        elseif ($Stats -eq 'denied') { $DeniedCount += 1 }
        elseif ($Stats -eq 'responded') { $ResponseCount += 1 }
        elseif ($Stats -eq 'ghosted') { $GhostedCount += 1 }
        else { $UncertainCount += 1 }

      } # foreach

      foreach ($SkillString in $Skills) {
        # TEST: Capture dynamic skills from the row
        if (-not [string]::IsNullOrWhiteSpace($SkillString)) {
          $CleanedSkills = $SkillString.Split(',') | ForEach-Object { $_.Trim().ToLower() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } # Split by comma, strip whitespace, make lowercase
          $MasterSkillList += $CleanedSkills # Add them to collection natively
        }
      }
    }
    catch {
      Write-Warning "Pipeline Row Processing Failed! Reason: $($_.Exception.Message)"
    } 
  } # PROCESS


  END {

    try {
      
      $total = $HiredCount + $DeniedCount + $ResponseCount + $UncertainCount + $GhostedCount + $InterviewCount # accumulated totals

      $DaysPast = "Unknown"
      if ($FirstDate) {
        # get the days since the first application
        $DaysPast = [math]::Round(((Get-Date) - $FirstDate).TotalDays, 0) # the math is mathing - calculating the total days since the first application was sent
      }
    
      # ======================================== #
      #                   DISPLAY                #
      # ======================================== #
    
      [PSCustomObject]@{ # The object that will be outputted to the pipeline with all the analytics
        CampaignStartDate = $FirstDate.ToString("yyyy-MM-dd")
        DaysSinceStart    = $DaysPast
        TotalApplications = $total
        Interviewed       = $InterviewCount
        Hired             = $HiredCount
        Denied            = $DeniedCount
        Responded         = $ResponseCount
        Uncertain         = $UncertainCount
        Ghosted           = $GhostedCount

        # test telemetry for skills to show if it capture value
        # skillsvariable    = $Skills
        # skillslist        = $MasterSkillList
      }

      # ======================================== # the main logic for analyzing the emotional damage based on the response rates and uncertainty
      #             MAIN LOGIC                   # i should have used switch cases but this is more fun to write "says no one ever", the real reson is just it keeps on expanding,
      # ======================================== # it's started with only two logic branches and then i kept on adding more and more as i thought of more scenarios to analyze, so it ended up like this

      $ValidResponses = $DeniedCount + $ResponseCount
      if ($ValidResponses -gt 0) {
        if ($uncertaincount -gt ($DeniedCount + $ResponseCount)) {
          write-warning "high uncertainty detected: $([math]::round(($UncertainCount / $total * 100), 2))%"
        }
        elseif ($HiredCount -gt 0) {
          write-host "Congratulations! You got hired in $DaysPast days with a response rate of $([math]::round(($ResponseCount / $total * 100), 2))%!" -ForegroundColor Green
        }
        elseif ($DeniedCount -gt $ResponseCount) {
          write-warning "high denial rate detected: $([math]::round(($DeniedCount / ($DeniedCount + $ResponseCount) * 100), 2))%"
        }
        elseif ($ResponseCount -gt $DeniedCount) {
          write-host "Application status looks good: $([math]::round(($ResponseCount / ($DeniedCount + $ResponseCount) * 100), 2))% responded" -ForegroundColor Green
        }
      } # if

      # ======================================== #
      #               FIX COUNTER                # fix analization for ghosting and uncertain rates
      # ======================================== #

      if ($GhostedCount -gt 0 -and $total -gt 0) {
        Write-Host "Ghosting rate : $([math]::round(($GhostedCount / $total * 100), 2))%" -ForegroundColor Yellow
      } # if
      if ($total -gt 0) {
        Write-Host "Uncertain rate: $([math]::round(($UncertainCount / $total * 100), 2))%" -ForegroundColor Yellow
      } # if

      # ======================================== #
      #      TEST: DYNAMIC SKILL LEADERBOARD     #
      # ======================================== #

      if ($MasterSkillList.Count -gt 0) {
        Write-Host "`n--- MARKET ANALYSIS ON SKILLSETS ---" -ForegroundColor Cyan
        
        $SkillLeaderboard = $MasterSkillList | 
        Group-Object | # Group similar items, count them, and sort descending (highest demand first)
        Select-Object @{Name = 'Skill'; Expression = { $_.Name } }, Count | 
        Sort-Object Count -Descending | Select-Object -first 15

        $SkillLeaderboard | Format-Table
      }
    }
    catch {
      Write-Warning "Failed to generate final report analytics: $($_.Exception.Message)"
    }
  } # END
} # function

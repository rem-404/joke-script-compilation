<#
Skill Purge V_1.4

parse a textfile to extract skills on the see of corporate buzzwords
copy it directly to the clipboard
ready to be pasted to the CsvOfDisappointment.csv
eliminates manual parsing and typing of skill
this will provide a proper statistics of current indemand skill (skills appearing multiple times) if paired with 
  Get-EmotionalDamageAnalytics script
  CsvOfDisappointment file
#>

function Get-SkillParse {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$FilePath = "C:\Logs\text\jobdesc.txt"
  )
  
  BEGIN {

    # ======================================== #
    #                SKILL POOL                #
    # ======================================== #

    # Skill matching pool

    <#
        $KnownSkills = @(
      'powershell', 'active directory', 'azure', 'itil', 'ccna', 
      'vmware', 'windows server', 'linux', 'networking', 'intune',
      'hyper-v', 'exchange', 'microsoft 365', 'vpn', 'firewall'
    )
    #>

    # Expanded pool (AI Assisted pool table)
    $KnownSkills = @(

      # ======================================== #
      #             CORE FOUNDATIONAL            #
      # ======================================== #

      # --- CORE SYSTEMS & OS ---
      'windows server', 'win server', 'winsvr', 'active directory', 'activedirectory', 'ad', 
      'group policy', 'gpo', 'dns', 'dhcp', 'wins', 'ntfs', 'dfs', 'file server', 
      'print server', 'iis', 'web server', 'linux', 'unix', 'ubuntu', 'centos', 'redhat', 
      'debian', 'suse', 'bash', 'shell scripting', 'powershell', 'pwsh', 'command line', 
      'cmd', 'terminal', 'registry', 'task scheduler', 'performance monitor', 'perfmon',
      'resource monitor', 'event viewer', 'logs', 'syslog', 'patch management', 'wsus',

      # --- VIRTUALIZATION & INFRASTRUCTURE ---
      'virtualization', 'vmware', 'esxi', 'vcenter', 'vsphere', 'hyper-v', 'hyperv', 
      'microsoft hyper-v', 'proxmox', 'kvm', 'qemu', 'virtualbox', 'vm', 'virtual machine', 
      'cluster', 'failover cluster', 'high availability', 'ha', 'dr', 'disaster recovery', 
      'backup', 'restore', 'veeam', 'acronis', 'storage', 'san', 'nas', 'iscsi', 'fiber channel',
      'raid', 'hardware', 'server hardware', 'dell emc', 'hp', 'hpe', 'lenovo', 'ibm',

      # --- NETWORKING ---
      'networking', 'tcp/ip', 'tcpip', 'ip address', 'subnet', 'subnetting', 'vlsm', 
      'gateway', 'routing', 'switching', 'vlan', 'trunking', 'ospf', 'bgp', 'eigrp', 
      'nat', 'pat', 'firewall', 'pfSense', 'fortinet', 'cisco asa', 'meraki', 'vpn', 
      'site-to-site', 'remote access', 'wan', 'lan', 'wlan', 'wifi', 'wireless', 
      'dns server', 'dhcp server', 'ftp', 'sftp', 'smb', 'cifs', 'ping', 'tracert', 
      'nslookup', 'wireshark', 'packet capture', 'qos', 'bandwidth', 'latency', 'ccna', 'cisco',

      # --- MICROSOFT 365 / CLOUD IDENTITY ---
      'microsoft 365', 'ms 365', 'm365', 'office 365', 'o365', 'exchange', 'exchange online', 
      'outlook', 'entra id', 'azure ad', 'aad', 'identity', 'authentication', 'mfa', 
      'multi-factor', 'sso', 'single sign-on', 'intune', 'mdm', 'mobile device management', 
      'endpoint manager', 'compliance', 'security center', 'defender', 'defender for endpoint', 
      'defender for office 365', 'sharepoint', 'onedrive', 'teams', 'admin center',

      # --- CLOUD PLATFORMS ---
      'azure', 'microsoft azure', 'aws', 'amazon web services', 'gcp', 'google cloud', 
      'cloud computing', 'iaas', 'paas', 'saas', 'vm scale sets', 'app service', 
      'storage account', 'blob', 'virtual network', 'vnet', 'load balancer', 'application gateway',
      'azure ad connect', 'sync', 'hybrid identity', 'az900', 'az104', 'sysadmin',

      # --- SECURITY & COMPLIANCE ---
      'security', 'cyber security', 'antivirus', 'antimalware', 'encryption', 'bitlocker', 
      'tls', 'ssl', 'certificates', 'pki', 'access control', 'rbac', 'least privilege', 
      'audit', 'compliance', 'gdpr', 'iso 27001', 'nist', 'itil', 'itsm', 'servicenow', 
      'ticketing system', 'incident management', 'change management', 'problem management',

      # --- AUTOMATION & SCRIPTING ---
      'automation', 'scripting', 'coding', 'devops', 'ci/cd', 'ansible', 'puppet', 'chef', 
      'terraform', 'bicep', 'yaml', 'json', 'xml', 'api', 'rest api', 'graph api', 
      'microsoft graph', 'zapier', 'workflow', 'scheduled tasks', 'orchestration',

      # --- REMOTE & ENDPOINT ---
      'remote desktop', 'rdp', 'teamviewer', 'anydesk', 'vnc', 'ssh', 'remote support', 
      'endpoint', 'laptop', 'desktop', 'hardware troubleshooting', 'software installation', 
      'os deployment', 'mdt', 'sccm', 'endpoint configuration manager', 'internet',

      # --- GENERAL IT & SUPPORT ---
      'it support', 'technical support', 'helpdesk', 'l1 support', 'l2 support', 'l3 support', 
      'system administration', 'sysadmin', 'infrastructure', 'it operations', 'monitoring', 
      'nagios', 'zabbix', 'prometheus', 'grafana', 'log analytics', 'troubleshooting', 
      'problem solving', 'documentation', 'knowledge base', 'sop', 'standard operating procedure'

      # ======================================== #
      #              VENDOR SPECIFIC             #
      # ======================================== #

      # --- VENDOR NETWORKING & HARDWARE ---
      'ubiquiti', 'unifi', 'mikrotik', 'routeros', 'aruba', 'hpe aruba', 'sophos', 'palo alto', 'paloalto', 
      'pan-os', 'ruckus', 'tp-link', 'tplink', 'omada', 'sonicwall', 'watchguard', 'synology'

      # --- COLLABORATION & VOIP VENDORS ---
      'google workspace', 'g suite', 'gsuite', 'slack', 'zoom', 'avaya', 'webex', 'cisco webex', 
      'ringcentral', '8x8', 'voip', 'ip pbx', 'asterisk', '3cx'

      # --- ITSM & TICKETING VENDORS ---
      'jira', 'atlassian', 'zendesk', 'freshdesk', 'freshservice', 'manageengine', 'service desk plus', 'sysaid'

      # --- IDENTITY & SECURITY VENDORS ---
      'okta', 'ping identity', 'duo', 'duo security', 'yubikey', 'proofpoint', 'mimecast', 'trend micro'
    )
  }

  PROCESS {

    # ======================================== #
    #                 PARSNG                   #
    # ======================================== #
    if (Test-Path $FilePath) {
      $JobDesc = Get-Content $FilePath -Raw
      
      # Filter through known skills using strict word boundaries (\b)
      $FoundSkills = $KnownSkills | Where-Object {
        # This creates a regex like: \bactive directory\b
        # It ensures 'it' doesn't match 'security', and 'vpn' doesn't match 'development'
        $Pattern = "\b" + [regex]::Escape($_) + "\b"
        $JobDesc -match $Pattern
      }

      # ======================================== #
      #          CLIPBOARD and DISPLAY           #
      # ======================================== #

      if ($FoundSkills) {
        # Join and output to console, and put it in the clipboard
        $CleanOutput = $FoundSkills -join ', '
        $CleanOutput | Set-Clipboard

        Write-Host "[+] Skills Captured and Copied to Clipboard:" -ForegroundColor Green
        Write-Host "    $CleanOutput" -ForegroundColor DarkCyan

        $CleanOutput
      }
      else {
        Write-Warning "No matching skills found in the text sample."
      }
    }
    else {
      Write-Warning "Target file not found at path: $FilePath"
    }
  }

  END {}
}

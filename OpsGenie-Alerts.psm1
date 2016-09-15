<#
.SYNOPSIS
Powershell implementation of the OpsGenie Alerts API
.DESCRIPTION

.LINK
TODO: Add this module to github and add link to this field

#>


function New-OpsGenieAlert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [string]$Teams,
        [string]$Alias,
        [string]$Description,
        [string]$Recipients,
        [string]$Actions,
        [string]$Source,
        [string]$Tags,
        [object]$Details,
        [string]$Entity,
        [string]$User,
        [string]$Note
    )

    <#
        .SYNOPSIS
        Function to create OpsGenie alert via the OpsGenie Alerts API
        
        .DESCRIPTION


        .PARAMETER APIKey
        Specifies the Opsgenie APIKey required for authenticating to the OpsGenie RESTful API.

        .PARAMETER Message
        Alert text limited to 130 characters.

        .PARAMETER Teams
        List of team names which will be responsible for the alert. Team escalation policies are run to calculate which users will receive notifications. Teams which are exceeding the limit (50 teams) are ignored.

        .PARAMETER Alias
        Used for alert deduplication. A user defined identifier for the alert. There can be only one alert with open status with the same alias. Provides ability to assign a known id and later use this id to perform additional actions such as log, close, attach for the same alert. 

        .PARAMETER Description
        This field can be used to provide a detailed description of the alert, anything that may not have fit in the Message field. Limited to 15000 characters.

        .PARAMETER Recipients
        Optional user, group, schedule or escalation names to calculate which users will receive the notifications of the alert. Recipients which are exceeding the limit (50 recipients) are ignored.

        .PARAMETER Actions
        A comma separated list of actions that can be executed. Custom actions can be defined to enable users to execute actions for each alert. If Webhook Integration exists, webhook URL will be called when action is executed. Also if Marid Integration exists, actions will be posted to Marid. Actions will be posted to all existing bi-directional integrations too. Actions which are exceeding the number limit are ignored. Action names which are longer than length limit are shortened.

        .PARAMETER Source
        Field to specify source of alert. By default, it will be assigned to IP address of incoming request. Limited to 512 characters.

        .PARAMETER Tags
        A comma separated list of labels attached to the alert. You can overwrite Quiet Hours setting for urgent alerts by adding OverwritesQuietHours tag. Tags which are exceeding the number limit are ignored. Tag names which are longer than length limit are shortened.

        .PARAMETER Details
        Set of user defined properties. This will be specified as a nested JSON map such as: "details" : {"prop1":"prop1Value", "prop2":"prop2Value"} 

        .PARAMETER Entity
        The entity the alert is related to.

        .PARAMETER User
        Default owner of the execution. If user is not specified, the system becomes owner of the execution.

        .PARAMETER Note
        Additional alert note.

        .EXAMPLE
        New-OpsGenieAlert -APIKey "eb243592-faa2-4ba2-a551q-1afdf565c889" -Message "WebServer3 is down" -Teams ["operations", "developers"]
        Response will look like the following object:
        {
            "message" : "alert created",
            "alertId" : "d85b4c10-ca86-45f3-94a0-0685de932a86",
            "status" : "successful",
            "code" : 200
        }
    #>

    #Build Alert Request Body
    $body = @{
        "apiKey" = $APIKey
        "message" = $Message
        "teams" = $Teams
        "alias" = $Alias
        "description" = $Description
        "recipients" = $Recipients
        "actions" = $Actions
        "source" = $Source
        "tags" = $Tags
        "details" = $Details
        "entity" = $Entity
        "user" = $User
        "note" = $Note
    }
    if ($Message.Length -gt 130) {
        Write-Error "-Message length cannot exceed 130 characters."
    }

    #Invoke command to create alert using $body created above
    $alertApiURI = 'https://api.opsgenie.com/v1/json/alert'
    Invoke-RestMethod -Method Post -Uri $alertApiURI -Body (ConvertTo-Json $body)
}

function Get-OpsGenieAlert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        [string]$ID,
        [string]$Alias,
        [string]$TinyID,

        [switch]$ListNotes,
        [switch]$ListLogs,
        [switch]$ListRecipients,
        [string]$Limit,
        [string]$Order,
        [string]$LastKey
    )
}

function Get-OpsGenieAlertList {
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        [string]$CreatedAfter,
        [string]$CreatedBefore,
        [string]$UpdatedAfter,
        [string]$UpdatedBefore,
        [int]$Limit,
        [string][ValidateSet("open", "acked", "unacked", "seen", "notseen", "closed")]$Status,
        [string][ValidateSet("createdAt", "updatedAt")]$SortBy = "createdAt",
        [string][ValidateSet("asc", "desc")]$Order = "asc",
        [string]$Teams,
        [string]$Tags,
        [string][ValidateSet("and", "or")]$TagsOperator = "and",

        [switch]$Count
    )
    if ($Count) {
        if ($Limit -eq '') {
            $Limit = 100000
        }
        $baseURL = "https://api.opsgenie.com/v1/json/alert/count?apiKey="+$APIKey+'&limit='+$Limit+'&tagsOperator='+$TagsOperator
    }
    else {
        if ($Limit -eq '') {
            $Limit = 20
        }
        $baseURL = 'https://api.opsgenie.com/v1/json/alert?apiKey='+$APIKey+'&limit='+$Limit+'&order='+$Order+'&sortBy='+$SortBy+'&tagsOperator='+$TagsOperator
    }
    if ($CreatedAfter -ne '') {
        $baseURL += '&createdAfter='+$CreatedAfter
    }
    if ($CreatedBefore -ne '') {
        $baseURL += '&createdBefore='+$CreatedBefore
    }
    if ($UpdatedAfter -ne '') {
        $baseURL += '&updatedAfter='+$UpdatedAfter
    }
    if ($UpdatedBefore -ne '') {
        $baseURL += '&updatedBefore='+$UpdatedBefore
    }
    if ($Status -ne '') {
        $baseURL += '&status='+$Status
    }
    if ($Teams -ne '' -and $Count -ne $true) {
        $baseURL += '&teams='+$Teams
    }
    if ($Tags -ne '') {
        $baseURL += '&tags='+$Tags
    }
    Write-Host $baseURL
    return Invoke-RestMethod -Method Get -Uri $baseURL
}

function Set-OpsGenieAlert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        [string]$ID,
        [string]$Alias,

        [string]$User,
        [string]$Note,
        [string]$Source,

        [switch]$Acknowledge,
        [switch]$TakeOwnership,
        [switch]$AddNote,

        [switch]$Snooze,
        [string]$EndDate,

        [switch]$Renotify,
        [string]$Recipients,

        [switch]$Assign,
        [string]$Owner,

        [switch]$AddTeam,
        [string]$Team,

        [switch]$AddRecipient,
        [string]$Recipient,
        
        [switch]$AddTags,
        [switch]$RemoveTags,
        [string]$Tags,

        [switch]$AddDetails,
        [switch]$RemoveDetails,
        [string]$Details,

        [switch]$ExecuteAction,
        [string]$Action,

        [switch]$AttachFile,
        [string]$Attachment,
        [string]$IndexFile   
    )
}

function Close-OpsGenieAlert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        [string]$ID,
        [string]$Alias,

        [string]$User,
        [string]$Note,
        [string]$Source,

        [switch]$Delete
    )
    if (($ID -eq '' -and $Alias -eq '') -or ($ID -ne '' -and $Alias -ne '')) {
        Write-Error "One of -ID or -Alias parameters should be specified with close alert request. -Alias option can only be used for open alerts"
    }
    
    if ($Delete -eq $true) {
        $alertDeleteURI = 'https://api.opsgenie.com/v1/json/alert?apiKey='+$APIKey
        if ($ID -ne '') {
            $alertDeleteURI += '&id='+$ID
        }
        if ($Alias -ne '') {
            $alertDeleteURI += '&alias='+$Alias
        }
        if ($User -ne '') {
            $alertDeleteURI += '&user='+$User
        }
        if ($Source -ne '') {
            $alertDeleteURI += '&source='+$Source
        }
        return Invoke-RestMethod -Method Delete -Uri $alertDeleteURI
    }

    #Create body of request for closing an alert
    $body = @{
        "apiKey" = $APIKey
        "id" = $ID
        "alias" = $Alias
        "user" = $User
        "note" = $Note
        "source" = $Source
    }

    #Invoke command to close alert using $body created above
    $alertCloseURI = 'https://api.opsgenie.com/v1/json/alert/close'
    return Invoke-RestMethod -Method Post -Uri $alertCloseURI -Body (ConvertTo-Json $body)
}
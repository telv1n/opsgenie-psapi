#TODO: Add exit codes to all errors.

function New-OpsGenieAlert {
    <#
        .SYNOPSIS
        Create OpsGenie alerts via the OpsGenie Alerts API
        
        .DESCRIPTION
        This function programmatically allows for the creation of alerts via the OpsGenie Alerts RESTful API. Alerts are sent via POST using standard JSON notation.

        .PARAMETER APIKey
        Specifies the Opsgenie APIKey required for authenticating to the OpsGenie RESTful API.

        .PARAMETER Message
        Alert message text. This parameter is limited to 130 characters.

        .PARAMETER Teams
        List of team names which will be responsible for the alert. Team escalation policies are run to calculate which users will receive notifications. Teams which exceed the limit (50 teams) are ignored. Teams that do not exist will be ignored.

        .PARAMETER Alias
        Used for alert deduplication. A user defined identifier for the alert. There can be only one alert with open status with the same alias. Provides ability to assign a known id and later use this id to perform additional actions such as log, close, attach for the same alert. 

        .PARAMETER Description
        This field can be used to provide a detailed description of the alert, anything that may not have fit in the Message field. Limited to 15,000 characters.

        .PARAMETER Recipients
        Optional user, group, schedule or escalation names to calculate which users will receive the notifications of the alert. Recipients which are exceeding the limit (50 recipients) are ignored.

        .PARAMETER Actions
        A comma separated list of actions that can be executed. Custom actions can be defined to enable users to execute actions for each alert. If Webhook Integration exists, webhook URL will be called when action is executed. Also if Marid Integration exists, actions will be posted to Marid. Actions will be posted to all existing bi-directional integrations too. Actions which are exceeding the number limit are ignored. Action names which are longer than length limit are shortened.

        .PARAMETER Source
        Field to specify source of alert. By default, it will be assigned to IP address of incoming request. Limited to 512 characters.

        .PARAMETER Tags
        A comma separated list of labels attached to the alert. You can overwrite Quiet Hours setting for urgent alerts by adding OverwritesQuietHours tag. Tags which are exceeding the number limit are ignored. Tag names which are longer than length limit are shortened.

        .PARAMETER Details
        Set of user defined properties. This will be converted to a nested JSON map such as: "details" : {"prop1":"prop1Value", "prop2":"prop2Value"}.
        Takes a Powershell hash table object as input, ie. @{"prop1" = "prop1Value"; "prop2" = "prop2Value"}

        .PARAMETER Entity
        The entity the alert is related to.

        .PARAMETER User
        Default owner of the execution. If user is not specified, the system becomes owner of the execution.

        .PARAMETER Note
        Additional alert note.

        .EXAMPLE 
        New-OpsGenieAlert -APIKey "eb243592-faa2-4ba2-a551q-1afdf565c889" -Message "WebServer3 is down" -Teams "operations", "developers"

        Creates a new alert with message "WebServer3 is down" and assign it to the "operations" and "developers" teams.

        The command will return an object similar to the following:
        took    : 126
        code    : 200
        alertId : bdd95b05-9168-43f1-b878-c78e95beb222
        message : alert created
        status  : successful

        .EXAMPLE
        New-OpsGenieAlert -APIKey "eb243592-faa2-4ba2-a551q-1afdf565c889" -Message "Elevated CPU on server win-util1" -Teams "devops" -Recipients "John Doe" -Details @{"GitHub Link" = "https://github.com/telv1n/opsgenie-psapi/"; "Azure Portal" = "https://portal.azure.com"}
        
        New OpsGenie alert with team, recipients, and extra properties added. Note that when a recipient is added, the alert does not page out to the team(s) assigned.
        The object returned will be the same as the previous example indicates.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Array]$Teams,
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
    <#
        .SYNOPSIS
        Get details of an Alert via the OpsGenie Alerts API
        
        .DESCRIPTION
        This function extends the following endpoints of the OpsGenie Alerts API using switch parameters (see parameter definitions for complete details):
        -Get Alert Request
        -List Alert Notes Request
        -List Alert Logs Request
        -List Alert Recipients Request

        .PARAMETER APIKey
        Specifies the Opsgenie APIKey required for authenticating to the OpsGenie RESTful API.

        .PARAMETER ID
        ID of the alert to be retrieved.

        .PARAMETER Alias
        Alias of the alert to be retrieved. Using alias will only retrieve an open alert with that alias if it exists.

        .PARAMETER TinyID
        Short ID assigned to the alert. All requests support tinyId but using this field is not recommended because it rolls and may not be unique.

        .PARAMETER ListNotes
        The ListNotes switch parameter will retrieve the notes from a specified alert.

        .PARAMETER ListLogs
        The ListLogs switch parameter will retrieve the logs from a specified alert.

        .PARAMETER ListRecipients
        The ListNotes parameter will retrieve the recipients of a specified alert.

        .PARAMETER Limit
        Page size. Default is 100. This parameter is only used with either the ListNotes or the ListLogs switch parameters.

        .PARAMETER Order
        The order (according to timestamp) in which the results are returned. Accepts the following: [asc/desc]. The default order is descending. This parameter is only used with either the ListNotes or the ListLogs switch parameters.

        .PARAMETER LastKey
        Key which will be used in pagination. This parameter is only used with either the ListNotes or the ListLogs switch parameters.

        .EXAMPLE


        .EXAMPLE


        .EXAMPLE

    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        [string]$ID,
        [string]$Alias,
        [string]$TinyID,

        [switch]$ListNotes,
        [switch]$ListLogs,
        [switch]$ListRecipients,
        [int]$Limit = 100,
        [string][ValidateSet("asc", "desc")]$Order = "desc",
        [string]$LastKey
    )



    # Verify that only a single switch is used and set baseURL based on switch.
    if ($ListNotes -and !$ListLogs -and !$ListRecipients) {
        $baseURL = "https://api.opsgenie.com/v1/json/alert/note?apiKey=$APIKey&order=$Order"
        if ($ID -ne '') {
            $baseURL += '&id='+$ID
        }
        if ($Alias -ne '') {
            $baseURL += '&alias='+$Alias
        }
        if ($TinyID -ne '') {
            $baseURL += '&tinyId='+$TinyID
        }
        if ($LastKey -ne '') {
            $baseURL += '&lastKey='+$LastKey
        }
        return Invoke-RestMethod -Method Get -Uri $baseURL
    }

    elseif (!$ListNotes -and $ListLogs -and !$ListRecipients) {
        $baseURL = "https://api.opsgenie.com/v1/json/alert/log?apiKey=$APIKey&order=$Order"
        if ($ID -ne '') {
            $baseURL += '&id='+$ID
        }
        if ($Alias -ne '') {
            $baseURL += '&alias='+$Alias
        }
        if ($TinyID -ne '') {
            $baseURL += '&tinyId='+$TinyID
        }
        if ($LastKey -ne '') {
            $baseURL += '&lastKey='+$LastKey
        }
        return Invoke-RestMethod -Method Get -Uri $baseURL
    }

    elseif (!$ListNotes -and !$ListLogs -and $ListRecipients) {
       $baseURL = "https://api.opsgenie.com/v1/json/alert/recipient?apiKey=$APIKey"
        if ($ID -ne '') {
            $baseURL += '&id='+$ID
        }
        if ($Alias -ne '') {
            $baseURL += '&alias='+$Alias
        }
        if ($TinyID -ne '') {
            $baseURL += '&tinyId='+$TinyID
        }
        return Invoke-RestMethod -Method Get -Uri $baseURL 
    }

    elseif (!$ListNotes -and !$ListLogs -and !$ListRecipients) {
        $baseURL = "https://api.opsgenie.com/v1/json/alert?apiKey=$APIKey"
        if ($ID -ne '') {
            $baseURL += '&id='+$ID
        }
        if ($Alias -ne '') {
            $baseURL += '&alias='+$Alias
        }
        if ($TinyID -ne '') {
            $baseURL += '&tinyId='+$TinyID
        }
        Write-Host $baseURL
    }

    else {
        Write-Error "Please specify zero or one of -ListNotes, -ListLogs, -ListRecipients"
    }
}

function Get-OpsGenieAlertList {
    <#
        .SYNOPSIS
        List OpsGenie Alerts via the OpsGenie Alerts API
        
        .DESCRIPTION
        This function encapsulates both the List Alerts and List Alerts Count endpoints of the OpsGenie Alerts API. Count is accessible using the -Count switch parameter.

        .PARAMETER APIKey
        Specifies the Opsgenie APIKey required for authenticating to the OpsGenie RESTful API.

        .PARAMETER CreatedAfter
        

        .PARAMETER CreatedBefore


        .PARAMETER UpdatedAfter


        .PARAMETER UpdatedBefore
        

        .PARAMETER Limit


        .PARAMETER Status
        

        .PARAMETER SortBy


        .PARAMETER Order


        .PARAMETER Teams


        .PARAMETER Tags
        

        .PARAMETER TagsOperator

        
        .PARAMETER Count
        Switch parameter to request a count of alerts instead of a list of alerts. See the "Count Alerts Request" example.

        .EXAMPLE
        

        .EXAMPLE

    #>
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
    # Adds default limit if not specified for Count or List requests.
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

    # Add optional parameters to the baseURL if specified. Ignores them otherwise.
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

    #Send the request off to the OpsGenie Alerts API
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
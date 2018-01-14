function Get-LuasTimes
{
<#
.SYNOPSIS
    Makes a call to Dublin BUS API https://data.dublinked.ie and returns JSON blob of LUAS stops and times
 
.DESCRIPTION
    Makes a call to Dublin BUS API https://data.dublinked.ie and returns the routes, stops and stop times
 
.PARAMETER Operator
    Default is LUAS, because that all I cared about when writing this.
    Command can be used to call Irish Rail (IR),  Bus Atha Cliath / Dublin Bus (BAC), or Bus Éireann (BE) 

.PARAMETER RouteID  
    Specify the route you are looking at for LUAS this will be red or green

.PARAMETER StopID
    Specify the stop you are looking at stored in stopid use the following command to list stopid's
    (Get-LuasTimes -Operator LUAS -RouteID green).results.stops | ft
 
 .EXAMPLE
     List all of the routes for an operator LUAS 
        Get-LuasTimes -Operator LUAS 
    List all of the routes for an operator LUAS green Line
        Get-LuasTimes -Operator LUAS -RouteID green
    List stop information for Cheerywood
        Get-LuasTimes -StopID LUAS47
    Display the departure times for my LUAS stop
        Get-LuasTimes -StopID LUAS38 |  ? {$_.origin -like "*brid*"} | fl destination,duetime
        
.NOTES
    Author:  Kevin Miller
    Website: http://www.happymillfam.com
    Email: kevinm@wlkmmas.org
#>
  

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)][string]$Operator,
    [Parameter(Mandatory=$False)][string]$RouteID,
    # todo [Parameter(Mandatory=$False)][validateset("auto","ca","uk2","us","si",$null)][string]$StopID
    [Parameter(Mandatory=$False)][string]$StopID
)
process
    {
        If ($operator)
        {
            $OOperator = $operator
        }
        else
        {
            $OOperator = "LUAS"           
        }
        If ($RouteID)
        {
            $results = (Invoke-RestMethod -uri "https://data.dublinked.ie/cgi-bin/rtpi/routeinformation?routeid=$($RouteID)&operator=$($OOperator)&&format=json").results.stops 
        }
        elseif ($stopid) 
        {
            $results = (Invoke-RestMethod -uri "https://data.dublinked.ie/cgi-bin/rtpi/realtimebusinformation?operator=$($OOperator)&stopid=$($StopID)&format=json").results
        }
        else
        {
            $results = (Invoke-RestMethod -uri "https://data.dublinked.ie/cgi-bin/rtpi/routelistinformation?operator=$($OOperator)&format=json").results
        }
    return $results 
    }
}

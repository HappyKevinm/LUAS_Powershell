function Get-LuasTimesScrape
{
<#
.SYNOPSIS
    Makes a web call to https://www.luas.ie/index.php webpage and scrapes times
 
.DESCRIPTION
    Makes a web call to https://www.luas.ie/index.php webpage and scrapes times based on JSON stop list I stuck in GIT
    https://raw.githubusercontent.com/HappyKevinm/LUAS_Powershell/master/LuasStops.json" 
 
.PARAMETER LuasStop
    LUAS stop name needs to match correct formatting - you can tab then out to get the spelling 

.PARAMETER LuasDirection  
    Directions needs to be Inbound or Outbound towards the city center seems to be the logic

 .EXAMPLE
    Get times for The Gallops Stop Headed Inbound towards city center
        Get-LuasTimesScrape -LuasStop TheGallops -LuasDirection Inbound

        
.NOTES
    Author:  Kevin Miller
    Website: http://www.happymillfam.com
    Email: kevinm@wlkmmas.org
#>
  

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)][validateset("Cabra","Phibsborough","Grangegorman","BroadstoneDIT","Dominick","Parnell","Marlborough","Trinity","OConnellUpper","OConnellGPO","Westmoreland","Dawson","StStephensGreen","Harcourt","Charlemont","Ranelagh","Beechwood","Cowper","Milltown","WindyArbour","Dundru","Balally","Kilmacud","Stillorgan","Sandyford","CentralPark","Glencairn","TheGallops","LeopardstownValley","BallyoganWood","Carrickmines","Laughanstown","Cherrywood","BridesGlen","Tallaght","Hospital","Cookstown","Saggart","Fortunestown","CitywestCampus","Cheevertown","Fettercairn","Belgard","Kingswood","RedCow","Kylemore","Bluebell","Blackhorse","Drimnagh","Goldenbridge","SuirRoad","Rialto","Fatima","Jamess","Heuston","Museum","Smithfield","FourCourts","Jervis","AbbeyStreet","Busaras","Connolly","GeorgesDock","MayorSqureNCI","SpencerDock","ThePoint")][string]$LuasStop,
    [Parameter(Mandatory=$True)][validateset("Inbound","Outbound")][string]$LuasDirection
)


process
    {
        If (!$LuasStops)
        {
            Write-host -ForegroundColor Red "We don't have the Stop list. Optaining it from GIT - https://raw.githubusercontent.com/HappyKevinm/LUAS_Powershell/master/LuasStops.json "
            $LuasStops = Invoke-WebRequest -uri "https://raw.githubusercontent.com/HappyKevinm/LUAS_Powershell/master/LuasStops.json" | convertfrom-json 
        }
        $LuasStopURI = $LuasStops.Where({$_.Shortname -eq $LuasStop}).StopUriName
        write-host -ForegroundColor green "Looking up LUAS times for $($LuasStop) stops for trains going $($LuasDirection)"
        write-host -ForegroundColor magenta "URI used = https://www.luas.ie/index.php?id=346&get=$($LuasStopURI)&direction=$($LuasDirection)"
        $LuasData = Invoke-WebRequest -uri "https://www.luas.ie/index.php?id=346&get=$($LuasStopURI)&direction=$($LuasDirection)"
        $results = ($LuasData.ParsedHtml.childNodes | select innerText).innertext
        if (!$Results)
        {
            $results = "No Results returned. Sorry this happens from time to time - Try again"
        }
    return $results 
    }
} 
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

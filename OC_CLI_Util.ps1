#Authored by Myles Maskovich
#State of California, Department of Technology Services, Office of Digital Innovation

#Enter URL of your OpenShift Environment withouth ending / ex. https://openshift.com
$url = "https://ose.csil.cdt.ca.gov:8443"

#Fill out username and password and remove comments to keep your credentials permanently in place.
$username = $null
$password = $null
if ($username -eq $null) {$username = Read-Host "Enter your OpenShift Username"}
if ($password -eq $null) {$password = Read-Host "Enter Password"}

# Proj#n is your project name as it appears in the Name column when you type the command oc get projects.
# Proj# is the local folder location of your project. 
# Do this for each project you have so the script will automate selecting the correct local code repo.
#ex. $proj1n = "myprojectname"
#ex. $proj1 = "D:\my\project\folder"
$proj1n = $null
$proj1 = $null
$proj2n = $null
$proj2 = $null
$proj3n = $null
$proj3 = $null

function Show-Menu {
cls
""
""
"==========Main Menu=============" 
"================================"
"1: Login to OpenShift"
"2: Select Project"
"3: Select Pod"
"4: Create New Project"
"c: Custom Command"
#"i: Configure OC First Time" Coming Soon
"r: Rsync to active pod"
"l: Logout of OpenShift"
"q: Quit without logout"
"================================"
""
""
#Set Home Folder
$script:localfolder = ""
if ($env -eq $null) {OSlogin}
if ($env -contains "$proj1n") {$localfolder = $proj1}
if ($env -contains "$proj3n") {$localfolder = $proj3}
if ($env -contains "$proj4n") {$localfolder = $proj4}
if ($env -contains "$proj5n") {$localfolder = $proj5}
showenvironment
Clear-Variable -name password -Scope script
}



function showenvironment {
"=======Your Environment========="
#"OSE: $ose"
"Project: $env"
"Pod: $workpod"
"remote: $remotefolder"
"Local: $localfolder"
"================================"
}

function getprojects { 
                       
                        $projects = oc get projects
                        $output = $projects[1..$projects.Length]
                        $i = 1
                        $menuitem = @()
                        foreach ($_ in $output -match "Active") {
                        "$i $_"
                        $Array = $_.Split(" ")[0]
                        $menuitem += $Array
                        $i++
                        }
                        $MenuSel = Read-Host -prompt "Select which project to use"
                        $script:env = $menuitem[$MenuSel-1]
                        oc project $menuitem[$MenuSel-1]
                        
                        
}

function getpods {
                        $pods = oc get pods
                        $pod = $pods[1..$pods.Length]
                        $i = 1
                        $podmenu = @()
                        foreach ($_ in $pod -match "running") {
                        "$i $_"
                        $podArray = $_.Split(" ")[0] 
                        $podmenu += $podArray
                        $i++
                        }
                        $podMenuSel = Read-Host -prompt "Select which pod to use"
                        $script:workpod = $podmenu[$podMenuSel-1]
                        $script:remotefolder = oc rsh "$workpod" "pwd"
                        
}

function rsync {
$b = ":"
$o = "oc rsync --no-perms=true $localfolder $workpod$b$remotefolder"
Invoke-Expression $o
return
pause
}

function customcommand {
showenvironment
$command = Read-Host "Type custom command here"
Invoke-Expression $command
$command
pause

}

function OSlogin {
cls
requesttoken
invoke-expression $login
getprojects
getpods

}

function requesttoken {
if ($password -eq $null) {$password = Read-Host "Enter your password"}
$oauthurl = "$url/oauth/token/request"
$ie = New-Object -com InternetExplorer.Application 
$ie.visible=$false
$ie.navigate("$oauthurl") 
while($ie.ReadyState -ne 4) {start-sleep -m 100} 
$ie.document.getElementById("inputUsername").value= "$username" 
$ie.document.getElementById("inputPassword").value = "$password" 
$submit = $ie.document.getElementsByClassName("btn btn-primary btn-lg") | Select-Object -First 1
$submit.click()
while($ie.ReadyState -ne 4) {start-sleep -m 100} 
$out = $ie.Document.body.innertext
$Output = @()
$array = $out.Split(“`n”)
$script:login = $array[4]

}

do
{
     Show-Menu
     $input = Read-Host "Choose from the Main Menu"
     switch ($input)
     {
           '1' {cls; OSlogin}
           '2' {cls; getprojects} 
           '3' {cls; getpods}
           'c' {cls; customcommand}
           'r' {cls; rsync} 
           'l' {cls; oc logout; powershell}
           'q' {}
     }
}
until ($input -eq 'q')
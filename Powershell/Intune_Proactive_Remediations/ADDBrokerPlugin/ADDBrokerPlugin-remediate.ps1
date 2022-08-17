if(!(get-appxpackage -Name "Microsoft.AAD.BrokerPlugin")){
    #AAD BrokerPlugin missing 
    Add-AppxPackage -Register "C:\Windows\SystemApps\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\Appxmanifest.xml" -DisableDevelopmentMode -ForceApplicationShutdown
}
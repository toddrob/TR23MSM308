     # Login-AzureRmAccount
     #Variables
      $templatePath = $PSScriptRoot
      $TemplateFile = $templatePath + "\azuredeploy.json" 
      $TemplateParameterFile = $templatePath + "\azuredeploy.parameters.json" 
      $Location = "East US 2"       # Provide location for Deployment. IT should be West US
      $AvSet = "TestAvSet"     # Provide resource group name. It should be starting from ICTO number e.g. 2357-Alfred-UAT
      $resourceGroupName = "tdrapp14"      
      $destStorageAccount = "tdr401"    # Provide storage account details. e.g. 2357alfreduatsa
      $vmName = 'tdrilbvm'     # Provide the VMName. E.G. alfrediaasuat

      # Login to Azure Subscription

      # sign in
        Write-Host "Logging in..."
        try{
        $context = Get-AzureRmContext -ErrorAction silentlycontinue
        }
        catch{}
        if($context -eq $null)
        {
	        $cred = Add-AzureRmAccount;
        }

        if($SecurePassword -eq $null -or $UserDName -eq $null)
        {
            $UserDName = Read-Host -Prompt "Enter domain\username" 
	        $SecurePassword = Read-Host -Prompt "Enter password" -AsSecureString 
        } 
        
 

      
      #if (!$cred) { $cred = (Get-Credential).GetNetworkCredential() }
      # Login to Azure Portal
      #Login-AzureRmAccount -Credential $cred

      # Select the subscription id. Please do not change this
      $subscriptionId = "ef108bd8-8365-4b10-bd33-a9115e60ffb4"
      Select-AzureRmSubscription -SubscriptionID $subscriptionId;

      # Create requested resource group
    $exists = Get-AzureRmResourceGroup -Location $Location | Where-Object {$_.ResourceGroupName -eq $resourceGroupName}
    if (!$exists) {
        New-AzureRMResourceGroup -Name $resourceGroupName -Location $Location -Force
    }

      #Create the new storage account
      New-AzureRMStorageAccount -AccountName $destStorageAccount -Location $Location -ResourceGroupName $ResourceGroupName -Type "Standard_LRS"
      
    # Get my pwd for domain joining this VM
   # if (!$cred) { $cred = (Get-Credential).GetNetworkCredential() }

   
      # Do the new Azure deployment 
      New-AzureRmResourceGroupDeployment -Name -Verbose ($env:computername + (split-path ((ls).DirectoryName[0]) -leaf)).substring(0,5) -ResourceGroupName $resourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $TemplateParameterFile `
            -vmName $vmName   `
            -domainJoinUserName $UserDName `
            -domainJoinPassword $SecurePassword `
            -localAdminUserName 'todd' `
            -localAdminPassword $SecurePassword `
            -localAdmins $UserDName `
            -userImageStorageAccountName $destStorageAccount `
            -numberOfInstances 2 
           


#
# Cookbook Name:: wsfc
# Recipe:: create
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Add node to cluster if it is a replica
powershell_script 'Wait-Cluster' do
  code <<-EOH
      try{
          Add-ClusterNode $env:COMPUTERNAME -Cluster "#{node['wsfc']['cluster_name']}" -NoStorage
      }
      catch{}
  EOH
  guard_interpreter :powershell_script
  only_if <<-EOH
    $node = $true
    try{
        $list = Get-ClusterNode -Cluster #{node['wsfc']['cluster_name']}
        foreach($n in $list){
            if($n.Name -eq $env:COMPUTERNAME){
                $node = $false
            }
        }
    }
    catch{}
    $node
  EOH
end

# Give the node permissions on the cluster 
powershell_script 'Grant node cluster access' do
  code <<-EOH
    $nodeName = $env:USERDNSDOMAIN + "\" + $env:COMPUTERNAME + "$"
    Grant-ClusterAccess $nodeName -Full
  EOH
  guard_interpreter :powershell_script
  only_if <<-EOH
    (Get-ClusterAccess | where {$_.IdentityReference -like "*$env:COMPUTERNAME*"}).Count -eq 0
  EOH
end

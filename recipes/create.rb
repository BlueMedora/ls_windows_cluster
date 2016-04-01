#
# Cookbook Name:: ls_windows_cluster
# Recipe:: create
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

windows_feature "Failover-Clustering" do
  action :install
  all true
  provider :windows_feature_powershell
end

windows_feature "RSAT-Clustering" do
  action :install
  all true
  provider :windows_feature_powershell
end

windows_feature "RSAT-Clustering-CmdInterface" do
  action :install
  all true
  provider :windows_feature_powershell
end

# Build Cluster if it doesn't exist

if node['ls_windows_cluster']['cluster_role'] == 'creator' 
  powershell_script 'Build-Cluster' do
    code <<-EOH
      New-Cluster -Name "#{node['ls_windows_cluster']['cluster_name']}" -Node $env:COMPUTERNAME -StaticAddress #{node['ls_windows_cluster']['cluster_ip_address']} -NoStorage -Force    
    EOH
    guard_interpreter :powershell_script
    only_if <<-EOH
      (Get-Cluster -Name "#{node['ls_windows_cluster']['cluster_name']}" -Domain ((Get-WmiObject Win32_ComputerSystem).Domain)).Count -eq 0
    EOH
  end
end

# Add node to cluster if it is a replica
if node['ls_windows_cluster']['cluster_role'] == 'replica'
  powershell_script 'Wait-Cluster' do
    code <<-EOH
        try{
            Add-ClusterNode $env:COMPUTERNAME -Cluster "#{node['ls_windows_cluster']['cluster_name']}" -NoStorage
        }
        catch{}
    EOH
    guard_interpreter :powershell_script
    only_if <<-EOH
      $node = $true
      try{
          $list = Get-ClusterNode -Cluster #{node['ls_windows_cluster']['cluster_name']}
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
end

# Set Host record time to live to 300 seconds
powershell_script 'Set-HostRecordTTL' do
  code <<-EOH
    Get-ClusterResource "Cluster Name" | Set-ClusterParameter HostRecordTTL 300
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    (Get-ClusterResource "Cluster Name" | Get-ClusterParameter | where {$_.Name -eq "HostRecordTTL"}).Value -eq 300
  EOH
end

# Set Publish PTR Record to 1
powershell_script 'Set-PublishPTRRecords' do
  code <<-EOH
    Get-ClusterResource "Cluster Name" | Set-ClusterParameter PublishPTRRecords 1
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    (Get-ClusterResource "Cluster Name" | Get-ClusterParameter | where {$_.Name -eq "PublishPTRRecords"}).Value -eq 1
  EOH
end 

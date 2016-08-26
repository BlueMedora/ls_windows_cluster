#
# Cookbook Name:: wsfc
# Recipe:: create
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Build Cluster if it doesn't exist
powershell_script 'Build-Cluster' do
  code <<-EOH
    New-Cluster -Name "#{node['wsfc']['cluster_name']}" -Node $env:COMPUTERNAME -StaticAddress #{node['wsfc']['cluster_ip_address']} -NoStorage -Force
  EOH
  guard_interpreter :powershell_script
  only_if <<-EOH
    (Get-Cluster -Name "#{node['wsfc']['cluster_name']}" -Domain ((Get-WmiObject Win32_ComputerSystem).Domain)).Count -eq 0
  EOH
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

#
# Cookbook Name:: ls_windows_cluster
# Recipe:: create
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

windows_feature 'Failover-Clustering' do
  action :install
  all true
  provider :windows_feature_powershell
end

windows_feature 'RSAT-Clustering' do
  action :install
  all true
  provider :windows_feature_powershell
end

windows_feature 'RSAT-Clustering-CmdInterface' do
  action :install
  all true
  provider :windows_feature_powershell
end

# Build Cluster if it doesn't exist

if node['windows-cluster']['cluster_role'] == 'creator'

  powershell_script 'Build-Cluster' do
    code <<-EOH
      New-Cluster -Name #{node['windows-cluster']['cluster_name']} -Node $env:COMPUTENAME -StaticAddress #{node['windows-cluster']['cluster_ip_address']} -NoStorage -Force    
    EOH
    guard_interpreter :powershell_script
    only_if <<-EOH
      (Get-Cluster -Name #{node['windows-cluster']['cluster_name']} -Domain ((Get-WmiObject Win32_ComputerSystem).Domain)).Count -eq 0
    EOH
  end
end


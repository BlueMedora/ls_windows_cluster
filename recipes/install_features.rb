#
# Cookbook Name:: wsfc
# Recipe:: create
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

windows_feature 'Failover-Clustering' do
  action :install
  all true
  provider :windows_feature_powershell
end


windows_feature 'RSAT-Clustering-Mgmt' do
  action :install
  all true
  provider :windows_feature_powershell
end


windows_feature 'RSAT-Clustering-PowerShell' do
  action :install
  all true
  provider :windows_feature_powershell
end

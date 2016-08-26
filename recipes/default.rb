#
# Cookbook Name:: wsfc
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Add the clustering features
include_recipe 'wsfc::install_features'

# If this is the first node, create the cluster from it
if node['wsfc']['cluster_role'] == 'creator'
  include_recipe 'wsfc::create_cluster'
# If this is not the first node, join the cluster
elsif node['wsfc']['cluster_role'] == 'replica'
  include_recipe 'wsfc::join_cluster'
end

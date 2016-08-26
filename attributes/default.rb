# Override tese 2 attributes with correct values
default['wsfc']['cluster_name'] = "testCluster"
default['wsfc']['cluster_ip_address'] = '10.0.3.231'

# Possible values of creator and replica, override for replica
default['wsfc']['cluster_role'] = "creator"

include_recipe "git"

bash "install-golang" do
  cwd Chef::Config[:file_cache_path]
  user node['go']['user']
  group node['go']['user']
  code <<-EOH
    mkdir -p  #{node['go']['install_dir']}
    rm -rf #{node['go']['install_dir']}/go
    tar -C #{node['go']['install_dir']} -xzf #{node["go"]["filename"]}
  EOH
  action :nothing
end

remote_file File.join(Chef::Config[:file_cache_path], node['go']['filename']) do
  source node['go']['url']
  checksum node['go']['checksum']
  action :create_if_missing
  mode 0755
  notifies :run, "bash[install-golang]", :immediately
  not_if "#{node['go']['install_dir']}/go/bin/go version | grep #{node['go']['version']}"
end

directory node['go']['gopath'] do
  action :create
  recursive true
  owner node['go']['user']
  group node['go']['user']
  mode 0755
end

directory node['go']['gobin'] do
  action :create
  recursive true
  owner node['go']['user']
  group node['go']['user']
  mode 0755
end

if node['go']['user'] != 'root'
  include_recipe "golang::bash_includes"
end

directory node['go']['shell_d'] do
  recursive true
  owner node['go']['user']
  group node['go']['user']
  mode 0755
end

template "#{node['go']['shell_d']}/golang.sh" do
  source "golang.sh.erb"
  owner node['go']['user']
  group node['go']['user']
  mode 0755
end
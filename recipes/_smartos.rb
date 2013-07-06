
# Service configuration
sensu_dir = node.sensu.directory
config_file = "#{sensu_dir}/config.json"
config_dir = "#{sensu_dir}/conf.d"
extension_dir = "#{sensu_dir}/extensions"
plugin_dir = "#{sensu_dir}/plugins"
handler_dir = "#{sensu_dir}/handlers"
log_file = "#{node.sensu.log_directory}/sensu-client.log"

# User for our daemon
group "sensu"
user "sensu" do
  gid "sensu"
end

# Install sensu gem
gem_package "sensu" do
  version node.sensu.version.gsub("-", ".")
  notifies :create, "ruby_block[sensu_service_trigger]", :immediately
end

# Create config and log folders
[
  sensu_dir,
  config_dir,
  extension_dir,
  plugin_dir,
  handler_dir,
  node.sensu.log_directory,
].each do |dir_name|
  directory dir_name do
    owner "sensu"
    group "sensu"
    mode 0755
  end
end

# Create the smf definition
smf "sensu-client" do
  user "sensu"
  group "sensu"
  start_command "sensu-client -b -c #{config_file} -d #{config_dir} -e #{extension_dir} -l #{log_file}"
  working_directory sensu_dir
  environment "PATH" => "/usr/bin:/bin:/opt/local/bin:#{plugin_dir}:#{handler_dir}"
end

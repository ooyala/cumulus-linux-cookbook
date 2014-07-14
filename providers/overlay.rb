#
# Author:: Bao Nguyen <ngqbao@gmail.com>
# Cookbook Name:: cumulus-linux
# Provider:: overlay
#
# Copyright 2014, Ooyala
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
use_inline_resources

require 'json'

action :set do
  ports_conf_path = "#{node.cumulus.dir}/ports.conf"
  Chef::Log.info "Applying port changes for #{new_resource.name.to_s}: to #{ports_conf_path}"

  switch = new_resource.hardware

  directory node.cumulus.dir do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end

  # read and create the port mapping
  template ports_conf_path do
    cookbook "cumulus-linux"
    source "ports.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      ports: switch.modes
    )
    notifies :restart, "service[switchd]"
  end

  # build the "physical" interfaces
  if node.kernel.machine != "ppc"
    execute "dummy" do
      command "modprobe dummy numdummies=#{switch.ports}"
      action :run
    end

    # simulating front panel ports
    ports = JSON.parse(switch.to_json)
    n = 0
    ports.each do |name,v|
      puts "DEBUG - PORT: #{name}"
      execute "links" do
        command "/sbin/ip link set name #{name} dev dummy#{n}"
        action :run
        not_if "/sbin/ip link show #{name}"
      end
      n = n + 1
    end

    # TODO: convert to chef HWRP
    #ip_link "swp1" do
    #  dev "dummy0"
    #  action :add
    #  status :up
    #  type :dummy
    #end

    # only needed to simulate switchd daemon
    gem_package "daemons"

    # start the fake "switchd"
    template "/etc/init.d/switchd" do
      cookbook "cumulus-linux"
      source "switchd.conf.init.erb"
      owner "root"
      group "root"
      mode "0755"
    end

    template "usr/sbin/switchd_control.rb" do
      cookbook "cumulus-linux"
      source "switchd_control.rb.erb"
      owner "root"
      group "root"
      mode "0644"
    end

    template "/usr/sbin/switchd.rb" do
      cookbook "cumulus-linux"
      source "switchd.rb.erb"
      owner "root"
      group "root"
      mode "0755"
    end
  end

  service "switchd" do
    supports :status => false, :restart => true, :reload => false
    action [ :start ]
  end
end

action :remove do
  ports_conf_path = "#{node.cumulus.dir}/ports.conf"
  Chef::Log.info "Applying port changes for #{new_resource.name.to_s}: to #{ports_conf_path}"

  if ::File.exists?(ports_conf_path)
    Chef::Log.info "Removing port changes for #{new_resource.name.to_s}: to #{ports_conf_path}"
    file ports_conf_path do
      action :delete
    end
    new_resource.updated_by_last_action(true)
  end
end

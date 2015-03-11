# Author:: Bao Nguyen <opensource-cookbooks@ooyala.com>
# Library:: ip_link_provider
# Resource:: ip_link
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

require 'chef/mixin/shell_out'
require 'chef/log'
require 'chef/mixin/command'
require 'chef/provider'
require 'chef/exceptions'
# require 'erb'

# Usage: ip link add [link DEV] [ name ] NAME
#                   [ txqueuelen PACKETS ]
#                   [ address LLADDR ]
#                   [ broadcast LLADDR ]
#                   [ mtu MTU ]
#                   type TYPE [ ARGS ]
#       ip link delete DEV type TYPE [ ARGS ]
#
#       ip link set { dev DEVICE | group DEVGROUP } [ { up | down } ]
#                    [ arp { on | off } ]
#                    [ dynamic { on | off } ]
#                    [ multicast { on | off } ]
#                    [ allmulticast { on | off } ]
#                    [ promisc { on | off } ]
#                    [ trailers { on | off } ]
#                    [ txqueuelen PACKETS ]
#                    [ name NEWNAME ]
#                    [ address LLADDR ]
#                    [ broadcast LLADDR ]
#                    [ mtu MTU ]
#                    [ netns PID ]
#                    [ netns NAME ]
#        [ alias NAME ]
#                    [ vf NUM [ mac LLADDR ]
#           [ vlan VLANID [ qos VLAN-QOS ] ]
#           [ rate TXRATE ] ]
#        [ master DEVICE ]
#        [ nomaster ]
#       ip link show [ DEVICE | group GROUP ]
#
# TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge }

# ip_link "dummy0" do
# dev "swp1"
# action :set
# status :up, :down
# hw_ether "mac"
# type "dummy"
# persist true
# end

class Chef
  class Provider
    class IPLink < Chef::Provider
      include Chef::Mixin::ShellOut

      def load_current_resource
        @current_resource ||= Chef::Resource::IPLink.new(new_resource.name)
        @current_resource.dev(new_resource.dev)
        @current_resource.persist(new_resource.persist.nil?)
        @current_resource
      end

      def action_add
        command = ip_link_add_command
        fallback_command = fallback_ip_link_add_command
        if link_exist?
          Chef::Log.debug("#{@new_resource} already created - nothing to do")
        else
          begin
            do_add(command)
          rescue Mixlib::ShellOut::ShellCommandFailed => e
            Chef::Log.info("#{@new_resource} Rescuing failed ip link add for #{@new_resource.path}")
            Chef::Log.debug("#{@new_resource} Exception when creating link #{@new_resource.path}: #{e}")
            do_add(fallback_command)
          end
        end
      end

      def action_delete
        ip_link_down
        remove_link
      end

      protected

      def do_add(command)
        create_link(command)
        # persist if persist?
      end

      def create_link(command)
        shell_out!(command)
        Chef::Log.info("#{@new_resource} Adding link #{@new_resource.dev}")
        Chef::Log.debug("#{@new_resource} Empty file at #{@new_resource.path} created using command '#{command}'")
      end

      def persist?
        @new_resource.persist.nil?
      end

      def _ip_link_add_command
        command = _get_link_add_command
        Chef::Log.debug("#{@new_resource} swap creation command is '#{command}'")
        command
      end

      def _get_link_add_command
        command = "ip link add {@new_resource.dev} type #{@new_resource.type}"
        Chef::Log.debug("#{@new_resource} command is '#{command}'")
        command
      end
    end
  end
end

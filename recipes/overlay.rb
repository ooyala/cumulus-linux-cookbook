#
# Author:: Bao Nguyen <ngqbao@gmail.com>
# Cookbook Name:: cumulus-linux
# Recipe:: overlay
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

# "build" a cumulus switch overlay on a standard Debian system

#::Chef::Recipe.send(:include, Cumulus)

case node.cumulus.model
when "AS6701_32X"
  conf = Cumulus::SwitchConfig.new(Accton::AS6701_32X::X_pipeline,Accton::AS6701_32X::Y_pipeline)

  (21..24).each do |i|
    Chef::Log.info conf[i]
    conf[i].set1x40g
  end

  cumulus_linux_overlay "AS6701_32X" do
    hardware conf
  end
end

Description
===========

This cookbook create a switch overlay on a vanilla Debian and also deploy on
Cumulus router/switch.

Requirements
============

## Testing
Acess to Debian Wheezy box

## Production
Access to Cumulus HCL [1] switches (Accton AS6701_32X which is what this cookbook was originally written for)

Attributes
==========

default[:cumulus][:dir] = "/etc/cumulus"
default[:cumulus][:model] = "AS6701_32X"

Usage
=====

include_recipe "cumulus-linux"

## Setup Hardware Ports
::Chef::Recipe.send(:include, Cumulus)
case node.cumulus.model
when "AS6701_32X"
  conf = Cumulus::SwitchConfig.new(Accton::AS6701_32X::X_pipeline,Accton::AS6701_32X::Y_pipeline)

  (21..24).each do |i|
    conf.front_panel_port(i).set4x10g
  end

  # ruby symbols do not have "-" in them so it get convert into "_"
  # use "cumulus_linux_overlay" instead of "cumulus-linux-overlay"
  cumulus_linux_overlay "AS6701_32X" do
    hardware conf
  end
end


Author and License
===================

__Author__ Bao Nguyen <ngqbao@gmail.com>

Copyright 2014, Ooyala Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[1] http://cumulusnetworks.com/support/linux-hardware-compatibility-list

Description
===========

This cookbook primary purpose is to create a switch overlay on a vanilla Debian and if deployed on the production switch build the correct Port configurations needed for Cumulus.

Requirements
============

## Testing
Acess to Debian Wheezy box

## Production
Access to Cumulus HCL switches (Accton AS6701_32X which is what this cookbook was originally written for)

Attributes
==========

Usage
=====

include_recipe "cumulus-linux"

# seting up the hardware ports and layout
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
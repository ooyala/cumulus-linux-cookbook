  include_recipe "cumulus-linux"

::Chef::Recipe.send(:include, Cumulus)

case node.cumulus.model
when "AS6701_32X"
  conf = Cumulus::SwitchConfig.new(Accton::AS6701_32X::X_pipeline,Accton::AS6701_32X::Y_pipeline)
  puts "SwitchConfig"
  puts conf.port(0).mode
  puts conf.port(0).mode
  puts conf.port(0).mode
  puts conf.port(0)
  t = conf.port(0)
  t.set4x10g
  puts t
  puts t.mode
  puts t.mode
  puts t.mode

  #(21..24).each do |i|
  #  #::Chef::Log.info "DEBUG - #{conf.port(i)}"
  #  conf.port(0).set1x40g
  #  ::Chef::Log.info "DEBUG - #{conf.port(0).mode}"
  #end

  puts "PortConfig"
  a = Cumulus::PortConfig.new(10, "x")
  puts a.mode
  puts a.mode
  puts a.mode

  a.set4x10g
  puts a.mode
  puts a.mode
  puts a.mode

  x = Cumulus::B.new()
  puts "BBBBBBBBBBBBBBBBB"
  puts "before"
  puts x.a
  x.c()
  puts "after"
  puts x.a


  puts "AAAAAAAAAAAAAAAAA"
  z = Cumulus::A.new()
  puts "init"
  puts z.port(0)
  puts z.port(0).a

  puts "assign"
  y = z.port(0)
  puts y.a

  puts "change"
  y.c()

  puts "after"
  puts y.a

  # ruby symbols do not have - so it get convert into _
  # use cumulus_linux_overlay here instead of cumulus-linux-overlay
  cumulus_linux_overlay "AS6701_32X" do
    hardware conf
  end
end

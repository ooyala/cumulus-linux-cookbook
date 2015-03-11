#
# Author:: Manas Alekar
# Author:: Bao Nguyen <opensource-cookbooks@ooyala.com>
# Cookbook Name:: cumulus-linux
# Library:: ports
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

require 'json'

module Accton
  module AS6701_32X
    # Standard pipeline info provided by Cumulus
    X_PIPELINE = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 24, 25, 26, 30, 31, 32]
    Y_PIPELINE = [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 27, 28, 29]
  end
end

module Cumulus
  class SwitchConfig
    def initialize(x = nil, y = nil)
      @ports = []
      x.each do |n|
        @ports << PortConfig.new(n, 'x')
      end

      y.each do |n|
        @ports << PortConfig.new(n, 'y')
      end
    end

    def [](n)
      @ports[n]
    end

    def front_panel_port(n)
      if (c = @ports.select { |o| o.id == n })
        puts "Found: #{c}"
        c.first
      else
        puts 'Not Found'
      end
    end

    def ports
      @ports.reduce(0) { |a, e| a + e.nports }
    end

    def from_json
    end

    def pipelines
      @ports.reduce({}) do |re, n|
        re[n.id] = n.pipeline
      end
    end

    def modes
      @ports.reduce({}) do |re, n|
        re[n.id] = n.mode
      end
    end

    def to_json
      @ports.reduce({}) { |a, e| a.merge(e.serialize) }.to_json
    end
  end

  class PortConfig
    attr_accessor :pipeline
    attr_accessor :id
    attr_accessor :mode

    def initialize(id, pipeline)
      @id       = id
      @pipeline = pipeline
      @mode    = :c1x40g
      @unit   = [PortUnit.new]
    end

    def set1x40g
      @mode  = :c1x40g
      @unit = [PortUnit.new]
    end

    def set4x10g
      @mode  = :c4x10g
      @unit = []
      4.times do |i|
        # start counting at 0
        @unit << PortUnit.new(i)
      end
    end

    def mode
      @mode == :c4x10g ? '4x10G' : '40G'
    end

    def nports
      @mode == :c1x40g ? 1 : 4
    end

    def serialize
      if @mode == :c1x40g
        {
          "swp#{@id}" => @unit[0].serialize
        }
      else
        @ports.reduce({}) do |re, n|
          re["swp#{@id}s#{n.id}"] = n.serialize
        end
      end
    end

    def deserialize
    end
  end

  class PortUnit
    attr_accessor :ip
    attr_accessor :id

    def initialize(id = nil)
      @state = :up
      @id = id
    end

    def serialize
      { id: @id, state: @state  }
    end

    def deserialize
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  conf = Cumulus::SwitchConfig.new(Accton::AS6701_32X::X_PIPELINE, Accton::AS6701_32X::Y_PIPELINE)
  puts conf.ports
  conf[0].set4x10g
  puts conf[10]
  puts conf[10].serialize

  (0..5).each do |i|
    puts "#{i} - #{conf[i].id}:#{conf[i].pipeline}"
  end

  puts conf.pipelines

  puts conf.modes

  puts conf.ports
  puts "select: #{conf.front_panel_port(1)}"
  puts "result: #{conf.front_panel_port(1).mode}"
  conf.front_panel_port(1).set4x10g
  conf.front_panel_port(2).set4x10g
  puts conf.front_panel_port(2).mode
  puts conf.ports

  puts conf.to_json

  a = Cumulus::PortConfig.new(10, 'x')
  puts a.mode

  a.set4x10g
  puts a.mode
end

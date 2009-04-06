#!/usr/bin/env macruby

require 'hotcocoa'
include HotCocoa

application :name => "Hello ChiRb" do |app|
  app.delegate = self
  window (
    :frame => [500, 300, 200, 100], 
    :title => "Hello ChiRb") do |win|
    win << button(
      :title => "Click Me", 
      :on_action => lambda do |sender| 
        alert(:message => "Hello ChiRb!")
      end)
    win.will_close { exit }
  end
end

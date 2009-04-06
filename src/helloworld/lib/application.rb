require 'hotcocoa'

class Application

  def start
    application :name => "Helloworld" do |app|
      app.delegate = self
      window (
        :frame => [500, 300, 200, 100], 
        :title => "Helloworld") do |win|
        win << button(
          :title => "Hello!", 
          :on_action => lambda do |sender| 
            alert(:message => "hello world!")
          end)
        win.will_close { exit }
      end
    end
  end
  
  # file/open
  def on_open(menu)
  end
  
  # file/new 
  def on_new(menu)
  end
  
  # help menu item
  def on_help(menu)
  end
  
  # This is commented out, so the minimize menu item is disabled
  #def on_minimize(menu)
  #end
  
  # window/zoom
  def on_zoom(menu)
  end
  
  # window/bring_all_to_front
  def on_bring_all_to_front(menu)
  end
end

Application.new.start
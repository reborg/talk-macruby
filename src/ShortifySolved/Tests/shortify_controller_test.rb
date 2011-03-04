require File.dirname(__FILE__) + '/spec_helper'
require 'shortify_controller'
framework 'cocoa'

describe 'with long URLs' do

  before do
    @controller = ShortifyController.new
    @controller.input = NSTextField.new
    pasteboard = 'pasteboard'
    pasteboard.stubs(:stringForType).returns('some')
    NSPasteboard.stubs(:generalPasteboard).returns(pasteboard)
  end

  it 'copies the content of the clipboard' do
    @controller.pasteboard_to_input
    @controller.input.stringValue.should == 'some'
  end

end

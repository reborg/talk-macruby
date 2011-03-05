
class ShortifyController

  attr_accessor :input, :output
  
  def applicationDidFinishLaunching(sender)
    self.pasteboard_to_input
  end 

  def pasteboard_to_input
    pasteBoard = NSPasteboard.generalPasteboard
    @input.stringValue = pasteBoard.stringForType(NSStringPboardType) || ''
  end
  
  def shortify(sender)
    require 'net/http'
    result = Net::HTTP.get 'shortr.info', '/make-shortr.php?url=' + 
      @input.stringValue + '&format=plain'
    @output.stringValue = result.gsub('SUCCESS::', '')
    Url.create(:original=>@input.stringValue, :shortified => @output.stringValue)
  end
  
  def history(sender)
    NSAlert.alertWithMessageText('History',
      defaultButton: 'OK',
      alternateButton: nil,
      otherButton: nil,
      informativeTextWithFormat: Url.all.join(', ')).runModal
  end

end

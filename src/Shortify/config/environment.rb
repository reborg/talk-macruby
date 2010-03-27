APP_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
['bacon/lib', 'mocha/lib'].each do |path|
  $LOAD_PATH << APP_ROOT + '/vendor/gems/' + path
end
['/Classes'].each do |path|
  $LOAD_PATH << APP_ROOT + path
end

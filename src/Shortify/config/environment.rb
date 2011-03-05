APP_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH << APP_ROOT + '/Classes'
['bacon/lib', 'mocha/lib'].each do |path|
  $LOAD_PATH << APP_ROOT + '/vendor/gems/' + path
end

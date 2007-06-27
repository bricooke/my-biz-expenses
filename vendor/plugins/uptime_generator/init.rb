require 'rails_generator/base.rb'
require 'rails_generator/commands.rb'

%w(List Create Destroy).each do |c|
  eval("Rails::Generator::Commands::#{c}").send :include, eval("BTC::Commands::#{c}")
end


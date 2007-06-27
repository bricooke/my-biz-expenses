module BTC::Commands::Destroy
  def route_uptime
    look_for = "\n  map.success '/success.txt', :controller => 'uptime', :action => 'success'\n"
    logger.route "map.success '/success.txt'"
    gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
  end
end

module BTC::Commands::Create
  def route_uptime
    sentinel = 'ActionController::Routing::Routes.draw do |map|'

    logger.route "map.success '/success.txt'"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  map.success '/success.txt', :controller => 'uptime', :action => 'success'\n"
      end
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.success '/success.txt', :controller => 'uptime', :action => 'success'

  map.resources :categories do |categories|
    categories.resources :expenses
  end

  map.resources :expenses, :reports
  map.resources :users, :sessions
  
  map.signup   '/signup',        :controller => 'users',    :action => 'new'
  map.settings '/account',       :controller => 'users',    :action => 'edit'
  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate'
  map.send_reset_password '/reset_password', :controller => 'users', :action => 'send_reset_password'
  map.reset_password '/reset_password/:reset_password', :controller => 'users', :action => 'reset_password'
  map.login    '/login',         :controller => 'sessions', :action => 'new'
  map.logout   '/logout',        :controller => 'sessions', :action => 'destroy'
  
  map.connect '/', :controller => "users", :action => "new"
  map.connect ':controller/:action/:id'
end

ActionController::Routing::Routes.draw do |map|
  # See how all your routes lay out with "rake routes"

  map.connect '', :controller => 'site'

  map.resources :questions, :has_many => [:replies], :collection => {:search => :get}
  map.resources :passwords
  map.resources :users, :has_one => [:password], :has_many => [:replies]
  map.resource :session
  map.resources :beta_invitations

  map.home '', :controller => 'site'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.signin  '/signin', :controller => 'sessions', :action => 'create'
  map.signout '/signout', :controller => 'sessions', :action => 'destroy'
  map.privacy '/privacy', :controller => 'site', :action => 'privacy_policy'
  map.terms '/terms', :controller => 'site', :action => 'terms_of_service'
  map.about '/about', :controller => 'site', :action => 'about'
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  # Custom handle 404/500 errors
  map.notfound '*args', :controller => 'site', :action => 'custom404'
  
end

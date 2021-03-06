Rails.application.routes.draw do
  
  resources :events do
    #FIXME_AB: should be sessions not event_sessoins
    resources :event_sessions
  end
  

  #FIXME_AB: use REST
  get '/myevents' => 'events#my_events'
  get '/upcoming' => 'events#upcoming_events'
  get '/past' => 'events#past_events'
  get '/search' => 'events#search_events'
  get '/add_to_attendes_list' => 'events#add_to_attendes_list'
  get 'attending' => 'events#my_attending_events'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'events#index'

  get '/signin' => 'session#new', :as => :signin
  get '/auth/:provider/callback' => 'session#create'
  get '/signout' => 'session#destroy'
  get '/auth/failure' => 'session#failure'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

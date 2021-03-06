Rails.application.routes.draw do
  namespace :admin do
    # get "/stats" => "stats#stats"
    devise_scope :admin_user do
      get '/stats/:scope' => "stats#stats", as: :admin_stats
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
# ?  require 'sinatra'
  require 'sidekiq/web'
  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  ActiveAdmin.routes(self)
  resources :crush, only: [:index, :show], param: :slug do
    collection do
      get 'loading'
    end
  end
  get 'welcome/landing'

  # resources :instagram_interactions

  resources :instagram_media, only: [:index, :show], path: 'instagram/posts'
  resources :instagram_users, only: [:index, :show], path: 'instagram/users', param: :username

  devise_for :users, class_name: 'FormUser', :controllers => { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }
  root 'welcome#landing'
  get '/setup' => 'setup#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

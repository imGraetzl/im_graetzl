Rails.application.routes.draw do

  # routing concerns
  concern :address_before_new do
    collection do
      post 'new', as: :address
    end
  end

  resources :districts, path: 'wien', only: [:index, :show]

  ActiveAdmin.routes(self)

  devise_for :users,
    controllers: { registrations: 'registrations' },
    path_names: {
      sign_up: 'details', sign_in: 'login', sign_out: 'logout',
      password: 'secret', confirmation: 'verification',
      registration: 'registrierung', edit: 'edit/profile'
    }

  devise_scope :user do
    get 'users/registrierung/adresse', to: 'registrations#address', as: :user_registration_address
    post 'users/registrierung/adresse', to: 'registrations#set_address', as: :user_registration_set_address
    get 'users/registrierung/graetzl', to: 'registrations#graetzl', as: :user_registration_graetzl
    post 'users/registrierung/graetzl', to: 'registrations#set_graetzl', as: :user_registration_set_graetzl

    get 'users/notification_settings', to: 'notification_settings#index', as: :user_notification_settings
    post 'users/notification_settings/toggle_website_notification', to: 'notification_settings#toggle_website_notification', as: :user_toggle_website_notification
    post 'users/notification_settings/change_mail_notification', to: 'notification_settings#change_mail_notification', as: :user_change_mail_notification
    post 'users/notification_settings/mark_as_seen', to: 'notification_settings#mark_as_seen', as: :user_notifications_mark_as_seen
  end

  get 'static_pages/meetingCreate'
  get 'static_pages/meetingDetail'
  get 'static_pages/homeOut'
  get 'static_pages/userprofile'
  get 'static_pages/location'
  root 'static_pages#home'

  resources :notifications, only: [ :index ]

  resources :graetzls, only: [:index]
  resources :graetzls, path: '', only: [:show] do
    resources :meetings, path: 'treffen', only: [:index, :show, :new]
    resources :locations, only: [:index, :show]
  end

  resources :going_tos, only: [:create, :destroy]

  resources :locations, except: [:index, :show] do
    concerns :address_before_new
  end

  resources :meetings, path: 'treffen', except: [:index, :show] do
    resource :comments, module: :meetings, only: [:create]
  end

  resources :comments, only: [:update, :destroy]
  
  resources :posts, only: [:create] do
    resource :comments, module: :posts, only: [:create]
  end

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

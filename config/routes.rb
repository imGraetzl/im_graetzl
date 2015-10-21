Rails.application.routes.draw do

  post 'worker/daily_mail', to: 'worker#daily_mail'
  post 'worker/weekly_mail', to: 'worker#weekly_mail'
  post 'worker/backup', to: 'worker#backup'
  # routing concerns
  concern :graetzl_before_new do
    collection do
      post 'new', as: :before_new
    end
  end

  resources :districts, path: 'wien', only: [:index, :show] do
    get '/leopoldstadt-1020/graetzlzuckerl', on: :collection, to: 'zuckerls#index', as: 'zuckerl'
    get :graetzls, on: :member
  end

  ActiveAdmin.routes(self)

  devise_for :users, skip: [:passwords, :confirmations, :registrations],
    controllers: {
      sessions: 'users/sessions',
    },
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
    }

  devise_scope :user do
    resource :password,
      path: 'users/passwort',
      controller: 'users/passwords',
      path_names: { new: 'neu' }
    resource :confirmation,
      only: [:new, :create, :show],
      path: 'users/bestaetigung',
      controller: 'users/confirmations',
      path_names: { new: 'neu' }
    resource :registration,
      only: [:new, :create, :destroy],
      path: 'users',
      controller: 'users/registrations',
      path_names: { new: 'registrierung' } do
        post :registrierung, as: :address, action: :new
        post :graetzl, as: :graetzl, action: :graetzl
        get :graetzl, as: :graetzls, action: :graetzl
      end

    post 'users/notification_settings/toggle_website_notification', to: 'notification_settings#toggle_website_notification', as: :user_toggle_website_notification
    post 'users/notification_settings/change_mail_notification', to: 'notification_settings#change_mail_notification', as: :user_change_mail_notification
    post 'users/notification_settings/mark_as_seen', to: 'notification_settings#mark_as_seen', as: :user_notifications_mark_as_seen
  end

  resources :users, only: [:show, :update] do
    resource :comments, module: :users, only: [:create]
  end

  resource :user, only: [:edit], path_names: { edit: 'einstellungen' } do
    member do
      get :locations
    end
  end

  get 'info/agb', to: 'static_pages#agb'
  get 'info/datenschutz', to: 'static_pages#datenschutz'
  get 'info/impressum', to: 'static_pages#impressum'
  get 'info/infos-zum-graetzlzuckerl', to: 'static_pages#zuckerl'
  get 'info/fragen-und-antworten', to: 'static_pages#faq'

  root 'static_pages#home'

  resources :notifications, only: [ :index ]

  resources :graetzls, path: '', only: [:show] do
    resources :meetings, path: 'treffen', only: [:index, :show, :new]
    resources :locations, only: [:index, :show]
    resources :users, only: [:index, :show]
    resources :posts, only: [:show]
  end

  resources :going_tos, only: [:create, :destroy]

  resources :locations, except: [:index, :show] do
    concerns :graetzl_before_new
  end

  resources :meetings, path: 'treffen', except: [:index, :show] do
    resource :comments, module: :meetings, only: [:create]
  end

  resources :comments, only: [:update, :destroy]

  resources :posts, only: [:create, :destroy] do
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

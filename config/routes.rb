Rails.application.routes.draw do

  # routing concerns
  concern :graetzl_before_new do
    collection do
      post 'new', as: :before_new
    end
  end

  resources :districts, path: 'wien', only: [:index, :show] do
    get '/leopoldstadt-1020/graetzlzuckerl', on: :collection, to: 'zuckerls#index', as: 'zuckerl'
    get :graetzls, on: :member
    resources :locations, module: :districts, only: [:index]
    resources :meetings, path: :treffen, module: :districts, only: [:index]
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
    resources :comments, module: :users, only: [:create]
  end

  resource :user, only: [:edit], path_names: { edit: 'einstellungen' } do
    resources :locations, module: :users, only: [:index]
    resources :zuckerls, module: :users, only: [:index]
  end

  get 'info/agb', to: 'static_pages#agb'
  get 'info/datenschutz', to: 'static_pages#datenschutz'
  get 'info/impressum', to: 'static_pages#impressum'
  get 'info/infos-zum-graetzlzuckerl', to: 'static_pages#zuckerl'
  get 'info/fragen-und-antworten', to: 'static_pages#faq'

  get 'startnew_in', to: 'static_pages#startnew_in'

  root 'static_pages#home'

  resources :notifications, only: [ :index ] do
    post :mark_as_seen, on: :collection
  end

  resources :graetzls, path: '', only: [:show] do
    resources :meetings, path: :treffen, only: [:index, :show, :new]
    resources :locations, only: [:index, :show]
    resources :zuckerls, only: [:index]
    resources :users, only: [:show]
    resources :posts, only: [:index]
    resources :user_posts, only: [:new, :create, :show]
  end

  resources :going_tos, only: [:create, :destroy]

  resources :locations, except: [:index, :show] do
    concerns :graetzl_before_new
    resources :zuckerls, except: [:index, :show]
  end

  resources :meetings, path: :treffen, except: [:index, :show] do
    resources :comments, module: :meetings, only: [:index, :create]
  end

  resources :zuckerls, only: [:new] do
    resource :billing_address, only: [:show, :create, :update]
  end

  resources :comments, only: [:create, :destroy]

  resources :posts, only: [:destroy] do
    resources :comments, module: :posts, only: [:index, :create]
  end
  resources :location_posts, only: [:create]
end

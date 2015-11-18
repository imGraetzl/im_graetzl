Rails.application.routes.draw do

  post 'worker/daily_mail', to: 'worker#daily_mail'
  post 'worker/weekly_mail', to: 'worker#weekly_mail'
  post 'worker/backup', to: 'worker#backup'
  post 'worker/truncate_db', to: 'worker#truncate_db'
  post 'worker/truncate_eb', to: 'worker#truncate_eb'
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
    resources :posts, module: :users, only: [:create]
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
    resources :meetings, path: :treffen, only: [:index, :show, :new]
    resources :locations, only: [:index, :show]
    resources :users, only: [:index, :show]
    resources :posts, only: [:show]
  end

  resources :going_tos, only: [:create, :destroy]

  resources :locations, except: [:index, :show] do
    concerns :graetzl_before_new
    resources :posts, module: :locations, only: [:create]
  end

  resources :meetings, path: :treffen, except: [:index, :show] do
    resources :comments, module: :meetings, only: [:create]
  end

  resources :comments, only: [:update, :destroy]

  resources :posts, only: [:destroy]
end

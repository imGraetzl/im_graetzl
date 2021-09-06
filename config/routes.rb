Rails.application.routes.draw do

  get 'errors/not_found'
  get 'errors/internal_server_error'
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'reports' => 'reports#index'
  get 'reports/mailchimp'
  get 'sitemap.xml' => redirect('https://s3.eu-central-1.amazonaws.com/im-graetzl-production/sitemaps/sitemap.xml.gz')
  get 'search' => 'search#index'
  get 'search/results' => 'search#results'
  get 'search/autocomplete' => 'search#autocomplete'
  get 'search/user' => 'search#user'

  ActiveAdmin.routes(self)

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
      path_names: { new: 'registrierung' }

    post 'users/notification_settings/toggle_website_notification', to: 'notification_settings#toggle_website_notification', as: :user_toggle_website_notification
    post 'users/notification_settings/change_mail_notification', to: 'notification_settings#change_mail_notification', as: :user_change_mail_notification
  end

  devise_for :users, skip: [:passwords, :confirmations, :registrations],
    controllers: {
      sessions: 'users/sessions',
    },
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
    }

  resources :users, only: [:show, :update]

  resource :user, only: [:edit], path_names: { edit: 'einstellungen' } do
    get 'locations'
    get 'tooltip'
    get 'raumteiler', action: 'rooms', as: 'rooms'
    get 'toolteiler', action: 'tool_offers', as: 'tool_offers'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
    get 'treffen', action: 'meetings', as: 'meetings'
  end

  resources :activities, only: [:index]
  resources :meetings, path: 'treffen', except: [:show] do
    post :attend, on: :member
    post :unattend, on: :member
    get 'compose_mail', on: :member
    post 'send_mail', on: :member

  end
  resources :zuckerls, only: [:index]
  resources :rooms, only: [:index]
  resources :groups, only: [:index]

  resources :locations do
    resources :zuckerls, path: 'zuckerl', except: [:index, :show]
    post :add_post, on: :member
    post :remove_post, on: :member
    post :comment_post, on: :member
    get :tooltip, on: :member
  end

  resources :campaign_users, path: '', only: [:new, :create] do
  end
  get 'muehlviertel', to: 'campaign_users#muehlviertel'
  get 'kaernten', to: 'campaign_users#kaernten'

  resources :room_demands, path: 'wien/raumteiler/raumsuche', except: [:index] do
    post 'toggle', on: :member
    get 'activate/:activation_code' => 'room_demands#activate', on: :member
    patch 'update_status', on: :member
  end
  resources :room_offers, path: 'wien/raumteiler/raum', except: [:index] do
    get 'select', on: :collection
    get 'activate/:activation_code' => 'room_offers#activate', on: :member
    get 'rental_timetable', on: :member
    get 'available_hours', on: :member
    get 'calculate_price', on: :member
    patch 'update_status', on: :member
    post 'toggle_waitlist', on: :member
    post 'remove_from_waitlist', on: :member
  end
  resources :room_calls, path: 'wien/raumteiler/open-calls', except: [:index] do
    get 'submission', on: :member
    post 'add_submission', on: :member
  end

  resources :room_rentals, only: [:new, :create, :edit, :update] do
    get 'calculate_price', on: :collection
    get 'address', on: :collection
    get 'choose_payment', on: :member
    post 'initiate_card_payment', on: :member
    post 'initiate_eps_payment', on: :member
    get 'complete_eps_payment', on: :member
    get 'summary', on: :member
    post 'cancel', on: :member
    post 'approve', on: :member
    post 'reject', on: :member
    post 'leave_rating', on: :member
  end

  resources :tool_offers, path: 'toolteiler' do
    get 'calculate_price', on: :member
    patch 'update_status', on: :member
  end

  resources :tool_rentals, only: [:new, :create, :edit, :update] do
    get 'choose_payment', on: :member
    get 'summary', on: :member
    post 'initiate_card_payment', on: :member
    post 'initiate_eps_payment', on: :member
    get 'complete_eps_payment', on: :member
    post 'cancel', on: :member
    post 'approve', on: :member
    post 'reject', on: :member
    post 'confirm_return', on: :member
    post 'leave_rating', on: :member
  end

  resources :going_tos, only: [:new, :create] do
    get 'choose_payment', on: :collection
    get 'summary', on: :collection
    post 'initiate_card_payment', on: :collection
    post 'initiate_klarna_payment', on: :collection
    post 'initiate_eps_payment', on: :collection
  end

  resources :groups, except: [:index] do
    resources :discussions, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      post :toggle_following, on: :member
    end
    resources :discussion_posts, only: [:create, :update, :destroy] do
      post :comments, action: :comment
    end
    post 'request_join', on: :member
    post 'accept_request', on: :member
    post 'reject_request', on: :member
    post 'remove_user', on: :member
    get 'compose_mail', on: :member
    post 'send_mail', on: :member
    post :toggle_user_status, on: :member
  end

  get 'messenger' => 'messenger#index'
  get 'messenger/start_thread'
  get 'messenger/fetch_thread'
  get 'messenger/fetch_thread_list'
  get 'messenger/fetch_new_messages'
  post 'messenger/post_message'
  post 'messenger/update_thread'

  get 'wien/raumteiler/raumsuche' => redirect('/wien/raumteiler')
  get 'wien/raumteiler/raum' => redirect('/wien/raumteiler')
  get 'raumteiler' => redirect('/wien/raumteiler')
  get 'dieselgasse' => redirect('/wien/raumteiler/open-calls/raumteiler-hub-dieselgasse')
  get 'mixit' => redirect('/wien/raumteiler/open-calls/raumteiler-hub-mix-it')
  get 'raumteilerfestival' => redirect('/wien/raumteiler/')

  resource :wien, controller: 'wien', only: [:show] do
    get 'visit_graetzl'
    get 'treffen', action: 'meetings', as: 'meetings'
    get 'locations', action: 'locations', as: 'locations'
    get 'raumteiler', action: 'rooms', as: 'rooms'
    get 'toolteiler', action: 'tool_offers', as: 'tool_offers'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
    get 'selbststaendige-fuer-selbststaendige' => redirect('/wien/special-events')
    get 'special-events', action: 'platform_meetings', as: 'platform_meetings'
    get 'treffen/category/:category', action: 'meetings', as: 'meetings_category'
    get 'locations/category/:category', action: 'locations', as: 'locations_category'
    get 'raumteiler/category/:category', action: 'rooms', as: 'rooms_category'
    get 'toolteiler/category/:category', action: 'tool_offers', as: 'tool_offers_category'
  end

  resources :districts, path: 'wien', only: [:show] do
    get 'graetzls', on: :member
    get 'treffen', action: 'meetings', as: 'meetings', on: :member
    get 'locations', on: :member
    get 'raumteiler', action: 'rooms', as: 'rooms', on: :member
    get 'gruppen', action: 'groups', as: 'groups', on: :member
    get 'toolteiler', action: 'tool_offers', as: 'tool_offers', on: :member
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls', on: :member
    get 'treffen/category/:category', action: 'meetings', as: 'meetings_category', on: :member
    get 'locations/category/:category', action: 'locations', as: 'locations_category', on: :member
    get 'raumteiler/category/:category', action: 'rooms', as: 'rooms_category', on: :member
    get 'toolteiler/category/:category', action: 'tool_offers', as: 'tool_offers_category', on: :member
  end

  get 'unterstuetzer-team', to: 'static_pages#mentoring'
  get 'info', to: 'static_pages#help'
  get 'info/raumteiler', to: 'static_pages#raumteiler'
  get 'info/toolteiler', to: 'static_pages#toolteiler'
  get 'info/gruppen', to: 'static_pages#groups'
  get 'info/anbieter-und-locations', to: 'static_pages#location'
  get 'info/events-und-workshops', to: 'static_pages#meetings'
  get 'info/agb', to: 'static_pages#agb'
  get 'info/datenschutz', to: 'static_pages#datenschutz'
  get 'info/impressum', to: 'static_pages#impressum'
  get 'info/infos-zum-graetzlzuckerl', to: 'static_pages#zuckerl'
  get 'info/fragen-und-antworten', to: 'static_pages#faq'
  get 'info/infos-zur-graetzlmarie', to: 'static_pages#graetzlmarie'
  get 'info/code-of-conduct', to: 'static_pages#code-of-conduct'
  get 'info/versicherung', to: 'static_pages#insurance'
  get 'info/danke', to: 'static_pages#supporter'

  post 'webhooks/stripe'
  post 'webhooks/mailchimp'
  get 'webhooks/mailchimp'

  get '/robots.txt' => 'static_pages#robots'

  root 'static_pages#home'

  get 'notifications/unseen_count'
  get 'notifications/fetch'

  resources :zuckerls, path: 'zuckerl', only: [:new] do
    resource :billing_address, only: [:show, :create, :update]
  end

  resources :comments, only: [:create, :destroy]

  get 'navigation/load_content'

  namespace :api do
    resources :meetings, only: [:index]
  end

  resources :graetzls, path: '', only: [:show] do
    get 'treffen', action: 'meetings', as: 'meetings', on: :member
    get 'locations', on: :member
    get 'raumteiler', action: 'rooms', as: 'rooms', on: :member
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls', on: :member
    get 'gruppen', action: 'groups', as: 'groups', on: :member
    get 'toolteiler', action: 'tool_offers', as: 'tool_offers', on: :member
    resources :meetings, path: 'treffen', only: [:show]
    resources :groups, path: 'gruppen', only: [:show]
    resources :locations, only: [:show]
    resources :users, only: [:show]
    get 'treffen/category/:category', action: 'meetings', as: 'meetings_category', on: :member
    get 'locations/category/:category', action: 'locations', as: 'locations_category', on: :member
    get 'raumteiler/category/:category', action: 'rooms', as: 'rooms_category', on: :member
    get 'toolteiler/category/:category', action: 'tool_offers', as: 'tool_offers_category', on: :member
  end

  if Rails.configuration.upload_server == :s3
    mount Shrine.presign_endpoint(:cache) => "/s3/params"
  elsif Rails.configuration.upload_server == :app
    mount Shrine.upload_endpoint(:cache) => "/upload"
  end

end

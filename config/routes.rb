Rails.application.routes.draw do

  get 'errors/not_found'
  get 'errors/internal_server_error'
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'reports' => 'reports#index'
  get 'reports/mailchimp'
  get 'sitemap.xml' => 'sitemaps#sitemap'
  get 'search' => 'search#index'
  get 'search/results' => 'search#results'
  get 'search/autocomplete' => 'search#autocomplete'
  get 'search/user' => 'search#user'
  get 'search/address' => 'search#address', as: 'address_search'

  root 'home#index'
  get  'home' => 'home#about', as: 'about_platform'
  post 'geolocation'  => 'home#geolocation'

  #scope controller: 'region_calls', path: 'gemeinden', as: 'region_calls' do
    get 'call-2022' => 'region_calls#call'
    post 'call-2022' => 'region_calls#create'
  #end

  ActiveAdmin.routes(self)

  if Rails.configuration.upload_server == :s3
    mount Shrine.presign_endpoint(:cache) => "/s3/params"
  elsif Rails.configuration.upload_server == :app
    mount Shrine.upload_endpoint(:cache) => "/upload"
  end

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
    get 'toolteiler', action: 'tools', as: 'tools'
    get 'coop-share', action: 'coop_demands', as: 'coop_demands'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
    get 'treffen', action: 'meetings', as: 'meetings'
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns'
    get 'region-einstellungen', action: 'favorite_graetzls', as: 'favorite_graetzls'
  end

  scope controller: 'regions', as: 'region', path: 'region'  do
    get 'karte', action: 'index', as: 'index'
    get 'treffen(/category/:category)', action: 'meetings', as: 'meetings'
    get 'locations(/category/:category)', action: 'locations', as: 'locations'
    get 'raumteiler(/category/:category)', action: 'rooms', as: 'rooms'
    get 'coop-share(/category/:category)', action: 'coop_demands', as: 'coop_demands'
    get 'toolteiler(/category/:category)', action: 'tools', as: 'tools'
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
    get 'special-events', action: 'platform_meetings', as: 'platform_meetings'
  end

  scope controller: 'districts', as: 'district', path: 'bezirk/:id' do
    root action: 'index', as: 'index'
    get 'graetzls'
    get 'treffen(/category/:category)', action: 'meetings', as: 'meetings'
    get 'locations(/category/:category)', action: 'locations', as: 'locations'
    get 'raumteiler(/category/:category)', action: 'rooms', as: 'rooms'
    get 'coop-share(/category/:category)', action: 'coop_demands', as: 'coop_demands'
    get 'toolteiler(/category/:category)', action: 'tools', as: 'tools'
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
  end

  resources :activities, only: [:index]
  resources :meetings, path: 'treffen', except: [:show] do
    post :attend, on: :member
    post :unattend, on: :member
    get 'compose_mail', on: :member
    post 'send_mail', on: :member
  end

  resources :zuckerls, only: [:index]

  resources :locations do
    resources :zuckerls, path: 'zuckerl', except: [:index, :show]
    post :add_post, on: :member
    post :remove_post, on: :member
    post :comment_post, on: :member
    post :add_menu, on: :member
    post :update_menu, on: :member
    post :remove_menu, on: :member
    post :comment_menu, on: :member
    get :tooltip, on: :member
  end

  resources :coop_demands, path: 'coop-share' do
    post 'toggle', on: :member
    get 'reactivate/:activation_code' => 'coop_demands#reactivate', on: :member
    patch 'update_status', on: :member
  end

  resources :crowd_campaigns, path: 'crowdfunding' do
    get 'start', on: :collection
    get 'edit_description', on: :member
    get 'edit_finance', on: :member
    get 'edit_rewards', on: :member
    get 'edit_media', on: :member
    get 'edit_finish', on: :member
    get 'edit_next_steps', on: :member
    get 'supporters', on: :member
    get 'comments', on: :member
    get 'statistics', on: :member
  end

  resources :crowd_pledges, only: [:new, :create] do
    post 'calculate_price', on: :collection
    get 'choose_amount', on: :collection
    get 'login', on: :collection
    get 'choose_payment', on: :member
    post 'initiate_card_payment', on: :member
    post 'initiate_eps_payment', on: :member
    get 'complete_eps_payment', on: :member
    get 'summary', on: :member
  end

  resources :rooms, only: [:index]
  resources :room_demands, path: 'raumsuche', except: [:index] do
    post 'toggle', on: :member
    get 'reactivate/:activation_code' => 'room_demands#reactivate', on: :member
    patch 'update_status', on: :member
  end
  resources :room_offers, path: 'raum', except: [:index] do
    get 'select', on: :collection
    get 'reactivate/:activation_code' => 'room_offers#reactivate', on: :member
    get 'rental_timetable', on: :member
    get 'available_hours', on: :member
    get 'calculate_price', on: :member
    patch 'update_status', on: :member
    post 'toggle_waitlist', on: :member
    post 'remove_from_waitlist', on: :member
  end
  resources :room_calls, path: 'open-calls', except: [:index] do
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

  resources :tools, only: [:index]
  resources :tool_demands, path: 'toolsuche', except: [:index] do
    patch 'update_status', on: :member
  end
  resources :tool_offers, path: 'toolteiler' do
    get 'select', on: :collection
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

  resources :groups do
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

  get 'unterstuetzer-team', to: 'static_pages#mentoring'
  get 'info', to: 'static_pages#info'
  get 'info/coop-share', to: 'static_pages#coop_demands'
  get 'info/raumteiler', to: 'static_pages#raumteiler'
  get 'info/toolteiler', to: 'static_pages#toolteiler'
  get 'info/gruppen', to: 'static_pages#groups'
  get 'info/anbieter-und-locations', to: 'static_pages#location'
  get 'info/events-und-workshops', to: 'static_pages#meetings'
  get 'info/agb', to: 'static_pages#agb'
  get 'info/datenschutz', to: 'static_pages#datenschutz'
  get 'info/impressum', to: 'static_pages#impressum'
  get 'info/zuckerl', to: 'static_pages#zuckerl'
  get 'info/code-of-conduct', to: 'static_pages#code-of-conduct'
  get 'info/danke', to: 'static_pages#supporter'
  get 'info/ueber-uns', to: 'static_pages#about_us'
  get 'info/meilensteine', to: 'static_pages#milestones'
  get 'info/presse', to: 'static_pages#press'


  post 'webhooks/stripe'
  post 'webhooks/mailchimp'
  get 'webhooks/mailchimp'

  get 'notifications/unseen_count'
  get 'notifications/fetch'

  get 'navigation/load_content'

  resources :zuckerls, path: 'zuckerl', only: [:new] do
    resource :billing_address, only: [:show, :create, :update]
  end

  resources :comments, only: [:create, :destroy]

  get 'robots.txt' => 'static_pages#robots'

  namespace :api do
    resources :meetings, only: [:index]
  end

  scope controller: 'campaign_users', path: 'campaign', as: 'campaign_users' do
    get 'muehlviertel'
    get 'kaernten'
    post '(:campaign)' => 'campaign_users#create'
  end

  # Redirects for legacy routes
  get 'wien(/*wien_path)' => 'redirect#wien', wien_path: /.*/
  get 'raum' => redirect('raumteiler')
  get 'raumsuche' => redirect('raumteiler')
  get 'muehlviertel' => redirect('https://muehlviertler-kernland.welocally.at')
  get 'kaernten' => redirect('https://kaernten.welocally.at')

  resources :graetzls, path: '', only: [:show] do
    get 'treffen(/category/:category)', action: 'meetings', as: 'meetings', on: :member
    get 'locations(/category/:category)', action: 'locations', as: 'locations', on: :member
    get 'raumteiler(/category/:category)', action: 'rooms', as: 'rooms', on: :member
    get 'toolteiler(/category/:category)', action: 'tools', as: 'tools', on: :member
    get 'coop-share(/category/:category)', action: 'coop_demands', as: 'coop_demands', on: :member
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls', on: :member
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns', on: :member
    get 'gruppen', action: 'groups', as: 'groups', on: :member
    resources :meetings, path: 'treffen', only: [:show]
    resources :groups, path: 'gruppen', only: [:show]
    resources :locations, only: [:show]
  end

end

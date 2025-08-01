Rails.application.routes.draw do

  authenticated :user, ->(user) { user.admin? } do
    mount DelayedJobWeb, at: "/delayed_job"
  end

  get 'errors/not_found'
  get 'errors/internal_server_error'
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'sitemap.xml' => 'sitemaps#sitemap'
  get 'search' => 'search#index'
  get 'search/results' => 'search#results'
  get 'search/autocomplete' => 'search#autocomplete'
  get 'search/user' => 'search#user'
  get 'search/address' => 'search#address', as: 'address_search'

  root 'home#index'
  get  'home' => 'home#about', as: 'about_platform'
  post 'geolocation' => 'home#geolocation'

  # Special CrowdBoosts
  get  '/raumbooster', to: redirect('/leerstand')
  get  '/viertelfonds', to: redirect('/leerstand')  

  get  '/leerstand', to: 'crowd_boosts#leerstand', as: :leerstand
  post '/leerstand', to: 'crowd_boosts#submit_contact_list_entry'

  get 'andocken' => redirect('/') #=> 'region_calls#call'
  post 'andocken' => 'region_calls#create'

  # Widgets
  get "/static-assets(/*path)", to: 'triage#static_asset', format: '', as: 'static_asset'
  get "widgets/cf/:id", to: 'widgets#crowdfunding', as: :crowdfunding_widget

  ActiveAdmin.routes(self)

  namespace :admin do
    get 'autocomplete/:resource', to: 'autocomplete#show', as: :autocomplete
  end

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

  resources :favorites do
    post :toggle_favorite, on: :member
    get 'results', on: :collection
  end

  resources :users, only: [:show, :update]

  resource :user, only: [:edit], path_names: { edit: 'einstellungen' } do
    get 'locations'
    get 'tooltip'
    get 'foerdermitgliedschaft', action: 'subscription', as: 'subscription'
    get 'rechnungsadresse', action: 'billing_address', as: 'billing_address'
    get 'zahlungsmethode', action: 'payment_method', as: 'payment_method'
    get 'payment_authorized', on: :member
    get 'raumteiler', action: 'rooms', as: 'rooms'
    get 'energieteiler', action: 'energies', as: 'energies'
    get 'raumbooster', action: 'room_boosters', as: 'room_boosters'
    get 'coop-share', action: 'coop_demands', as: 'coop_demands'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
    get 'treffen', action: 'meetings', as: 'meetings'
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns'
    get 'region-einstellungen', action: 'favorite_graetzls', as: 'favorite_graetzls'
    get 'favorites', action: 'favorites', as: 'favorites'
  end

  scope controller: 'regions', as: 'region', path: 'region'  do
    get 'karte', action: 'index', as: 'index'
    get 'treffen(/category/:category)', action: 'meetings', as: 'meetings'
    get 'locations(/category/:category)', action: 'locations', as: 'locations'
    get 'raumteiler(/category/:category)', action: 'rooms', as: 'rooms'
    get 'coop-share(/category/:category)', action: 'coop_demands', as: 'coop_demands'
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns'
    get 'energieteiler', action: 'energies', as: 'energies'
    get 'mach-mit', action: 'polls', as: 'polls'
    get 'gruppen', action: 'groups', as: 'groups'
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls'
  end

  scope controller: 'districts', as: 'district', path: 'bezirk/:id' do
    root action: 'index', as: 'index'
    get 'graetzls'
    get 'treffen(/category/:category)', action: 'meetings', as: 'meetings'
    get 'locations(/category/:category)', action: 'locations', as: 'locations'
    get 'raumteiler(/category/:category)', action: 'rooms', as: 'rooms'
    get 'coop-share(/category/:category)', action: 'coop_demands', as: 'coop_demands'
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns'
    get 'energieteiler', action: 'energies', as: 'energies'
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

  resources :zuckerls, path: 'zuckerl', except: [:show]

  resources :locations do
    post :add_post, on: :member
    post :update_post, on: :member
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
    get 'reactivate/:activation_token' => 'coop_demands#reactivate', on: :member
    patch 'update_status', on: :member
  end

  resources :crowd_campaigns, path: 'crowdfunding' do
    collection do
      get '/', action: :start, as: :start              # /crowdfunding calls the start method
      get 'start', to: redirect('/crowdfunding')       # Redirect /crowdfunding/start to /crowdfunding
      get 'load_collections', action: :load_collections # Separate route for Ajax request
    end
    post :add_post, on: :member
    post :update_post, on: :member
    post :remove_post, on: :member
    post :comment_post, on: :member
    post :send_mail, on: :member
    post :set_percentage, on: :member
    get 'edit_description', on: :member
    get 'edit_finance', on: :member
    get 'edit_rewards', on: :member
    get 'edit_media', on: :member
    get 'edit_finish', on: :member
    get 'posts', on: :member
    get 'comments', on: :member
    get 'supporters', on: :member
    get 'status', on: :member
    get 'stripe_connect_initiate', on: :member
    get 'stripe_connect_completed', on: :member
    get 'compose_mail', on: :member
    get 'download_supporters', on: :member
    patch 'update_status', on: :member

    resources :crowd_pledges, only: [:new, :create] do
      get 'choose_amount', on: :collection
      get 'login', on: :collection
      post 'calculate_price', on: :collection
      post 'pledge_comment', on: :member
    end

    resources :crowd_donation_pledges, only: [:new, :create] do
      get 'choice', on: :collection
      get 'login', on: :collection
    end
  end

  resources :crowd_pledges, only: [] do
    get 'choose_payment', on: :member
    get 'payment_authorized', on: :member
    get 'crowd_boost_charge', on: :member
    get 'summary', on: :member
    get 'details', on: :member
    get 'change_payment', on: :member
    get 'payment_changed', on: :member
    get 'unsubscribe/:unsubscribe_code', action: 'unsubscribe', on: :member
    patch 'crowd_boost_charge', to: 'crowd_pledges#update_crowd_boost_charge', on: :member
    post 'charge_returned', on: :member
    post 'charge_seen',     on: :member
  end

  resources :crowd_donation_pledges, only: [] do
    get 'summary', on: :member
    get 'details', on: :member
  end

  resources :energies, only: [:index]
  resources :energy_demands, path: 'suche-energiegemeinschaft', except: [:index] do
    patch 'update_status', on: :member
  end
  resources :energy_offers, path: 'energiegemeinschaft', except: [:index] do
    get 'select', on: :collection
    patch 'update_status', on: :member
  end

  resources :rooms, only: [:index]
  resources :room_demands, path: 'raumsuche', except: [:index] do
    post 'toggle', on: :member
    get 'reactivate/:activation_token' => 'room_demands#reactivate', on: :member
    patch 'update_status', on: :member
  end
  resources :room_offers, path: 'raum', except: [:index] do
    get 'select', on: :collection
    get 'reactivate/:activation_token' => 'room_offers#reactivate', on: :member
    get 'rental_timetable', on: :member
    get 'available_hours', on: :member
    get 'calculate_price', on: :member
    patch 'update_status', on: :member
    post 'toggle_waitlist', on: :member
    post 'remove_from_waitlist', on: :member

    resources :room_boosters, only: [:new, :create], path: 'raumbooster' do
    end
  end

  resources :room_rentals, only: [:new, :create, :edit, :update] do
    get 'calculate_price', on: :collection
    get 'address', on: :collection
    get 'choose_payment', on: :member
    get 'payment_authorized', on: :member
    get 'change_payment', on: :member
    get 'payment_changed', on: :member
    get 'summary', on: :member
    post 'cancel', on: :member
    post 'approve', on: :member
    post 'reject', on: :member
  end

  resource :subscription_plans, path: 'foerdermitgliedschaft'
  resources :subscriptions, path: 'mitgliedschaft' do
    get 'choose_payment', on: :member
    get 'payment_authorized', on: :member
    get 'summary', on: :member
    patch :resume, on: :member
  end
  resources :subscription_invoices

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

  resources :polls, path: 'mach-mit' do
    post :unattend, on: :member
    resources :poll_users, only: [:new, :create] do
    end
  end

  resources :crowd_boosts, only: [:index, :show], path: 'crowdfunding-booster' do
    get 'charges', on: :member
    get 'campaigns', on: :member
    resources :crowd_boost_charges, only: [:new, :create], path: 'charge' do
      get 'login', on: :collection
      get 'choose_region', on: :collection
      post 'calculate_price', on: :collection
    end
  end

  resources :crowd_boost_charges, path: 'crowd-boost-charge' do
    get 'choose_payment', on: :member
    get 'payment_authorized', on: :member
    get 'summary', on: :member
    get 'details', on: :member
  end

  get 'messenger' => 'messenger#index'
  get 'messenger/start_thread'
  get 'messenger/fetch_thread'
  get 'messenger/fetch_thread_list'
  get 'messenger/fetch_new_messages'
  post 'messenger/post_message'
  post 'messenger/update_thread'

  get 'cf/:id', to: 'crowd_campaigns#redirect'
  get 'unterstuetzer-team' => redirect('/')
  get 'good-morning-dates', to: 'static_pages#good_morning_dates'
  get 'balkonsolar-workshops', to: 'static_pages#balkonsolar', as: 'balkonsolar'
  get 'balkonsolar-workshops-in-wien', to: 'static_pages#balkonsolar_wien', as: 'balkonsolar_wien'

  get 'info', to: 'static_pages#info'
  get 'info/crowdfunding', to: 'static_pages#info_crowdfunding'
  get 'info/coop-share', to: 'static_pages#info_coop_demands'
  get 'info/raumteiler', to: 'static_pages#info_raumteiler'
  get 'info/gruppen', to: 'static_pages#info_groups'
  get 'info/anbieter-und-locations', to: 'static_pages#info_location'
  get 'info/events-und-workshops', to: 'static_pages#info_meetings'
  get 'info/energieteiler', to: 'static_pages#info_energieteiler'
  get 'info/zuckerl', to: 'static_pages#info_zuckerl'
  get 'info/newsletter', to: 'static_pages#info_newsletter'
  get 'info/agb', to: 'static_pages#agb'
  get 'info/datenschutz', to: 'static_pages#datenschutz'
  get 'info/impressum', to: 'static_pages#impressum'
  get 'info/code-of-conduct', to: 'static_pages#code-of-conduct'
  get 'info/ueber-uns', to: 'static_pages#about_us'
  get 'info/meilensteine', to: 'static_pages#milestones'
  get 'info/presse', to: 'static_pages#press'
  get 'info/danke' => redirect('foerdermitgliedschaft')


  post 'webhooks/stripe'
  post 'webhooks/stripe_connected'
  post 'webhooks/mailchimp'
  get 'webhooks/mailchimp'

  get 'notifications/unseen_count'
  get 'notifications/fetch'
  get 'notifications/admin'
  get 'notifications/admin_result'

  resources :notifications, only: [] do
    member do
      delete :notification_destroy
    end
  end

  get 'navigation/load_content'

  resources :zuckerls, path: 'zuckerl' do
    get 'voucher', on: :member
    get 'address', on: :member
    get 'choose_payment', on: :member
    get 'payment_authorized', on: :member
    get 'change_payment', on: :member
    get 'payment_changed', on: :member
    get 'summary', on: :member
  end

  resources :room_boosters, path: 'raumbooster' do
    get 'choose_payment', on: :member
    get 'payment_authorized', on: :member
    get 'summary', on: :member
  end

  resources :comments, only: [:create, :destroy]

  get 'robots.txt' => 'static_pages#robots'

  namespace :api do
    resources :meetings, only: [:index]
  end

# Redirects for legacy routes
  get 'wien(/*wien_path)', to: 'redirect#wien', wien_path: /.*/

  %w[raum raumsuche].each do |path|
    get path, to: 'redirect#rooms'
  end

  %w[energieteiler energiegemeinschaft suche-energiegemeinschaft].each do |path|
    get path, to: 'redirect#energies'
  end


  resources :graetzls, path: '', only: [:show] do
    get 'treffen(/category/:category)', action: 'meetings', as: 'meetings', on: :member
    get 'locations(/category/:category)', action: 'locations', as: 'locations', on: :member
    get 'raumteiler(/category/:category)', action: 'rooms', as: 'rooms', on: :member
    get 'coop-share(/category/:category)', action: 'coop_demands', as: 'coop_demands', on: :member
    get 'zuckerl', action: 'zuckerls', as: 'zuckerls', on: :member
    get 'crowdfunding', action: 'crowd_campaigns', as: 'crowd_campaigns', on: :member
    get 'energieteiler', action: 'energies', as: 'energies', on: :member
    get 'gruppen', action: 'groups', as: 'groups', on: :member
    resources :meetings, path: 'treffen', only: [:show]
    resources :groups, path: 'gruppen', only: [:show]
    resources :locations, only: [:show]
  end

end

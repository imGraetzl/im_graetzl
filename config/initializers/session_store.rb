Rails.application.config.session_store(:cookie_store,
  key: Rails.env.production? ? "_im_graetzl_session" : "wl_session_#{Rails.env}",
  domain: [
    Rails.application.config.imgraetzl_host,
    Rails.application.config.welocally_host,
  ],
)
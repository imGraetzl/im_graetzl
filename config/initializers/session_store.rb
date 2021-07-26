Rails.application.config.session_store(:cookie_store,
  key: '_im_graetzl_session',
  domain: ["imgraetzl.at", "welocally.at"],
)


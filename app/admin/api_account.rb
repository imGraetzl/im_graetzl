ActiveAdmin.register ApiAccount do
  config.filters = false

  permit_params :name, :api_key, :enabled
end

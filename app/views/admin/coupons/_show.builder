context.instance_eval do
  attributes_table do
    row :id
    row :region_id
    row :name
    row :description
    row :code
    row :stripe_id
    row :amount_off
    row :percent_off
    row :duration
    row :valid_from
    row :valid_until
    row :enabled
  end
end

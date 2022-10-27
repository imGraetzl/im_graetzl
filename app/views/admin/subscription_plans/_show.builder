context.instance_eval do
  attributes_table do
    row :id
    row :name
    row :amount
    row :interval
    row :stripe_id
  end
end

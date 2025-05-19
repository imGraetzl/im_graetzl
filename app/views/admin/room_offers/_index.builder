context.instance_eval do
  selectable_column
  id_column
  column :region
  column :slogan
  column :user
  column(:Kurzzeitmiete) {|r| r.rental_enabled }
  column(:boosted){|r| status_tag(r.boosted)}
  column :last_activated_at
  actions
end

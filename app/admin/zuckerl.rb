ActiveAdmin.register Zuckerl do
  menu parent: :locations

  after_save do |zuckerl|
    event = params[:zuckerl][:active_admin_requested_event]
    zuckerl.send("#{event}!") unless event.blank?
  end

  filter :location
  filter :title
  filter :description
  filter :flyer
  filter :aasm_state, as: :select, collection: Zuckerl.aasm.states_for_select
  filter :paid_at
  filter :created_at

  scope :all, default: true
  scope :paid
  scope :pending
  scope :live
  scope :cancelled

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :location_id,
                :title,
                :description,
                :flyer,
                :active_admin_requested_event,
                :paid_at,
                :image, :remove_image,
                :initiative_id
end

class Zuckerl < ActiveRecord::Base
  include AASM
  # class NotifierThing
  #   def initialize(zuckerl)
  #     @zuckerl = zuckerl
  #   end
  #
  #   def call
  #     puts "#{@zuckerl} HELLO HELLO HELLO"
  #   end
  # end

  attachment :image, type: :image
  attr_accessor :active_admin_requested_event

  belongs_to :location

  aasm do
    state :pending, initial: true
    state :paid
    state :live
    state :cancelled

    event :mark_as_paid, guard: lambda { paid_at.blank? } do
      # transitions from: :pending, to: :paid, after: lambda { NotifierThing.new(self).call }
      transitions from: :pending, to: :paid
      transitions from: :live, to: :live
    end

    event :put_live do
      transitions from: [:pending, :paid], to: :live
    end

    event :expire do
      transitions from: :live, to: :paid, guard: lambda { paid_at.present? }
      transitions from: :live, to: :pending
    end

    event :cancel do
      transitions to: :cancelled
    end
  end
end

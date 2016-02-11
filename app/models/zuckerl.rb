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

  after_create :send_booking_confirmation

  aasm do
    state :pending, initial: true
    state :paid
    state :live
    state :cancelled

    event :mark_as_paid, guard: lambda { paid_at.blank? }, after: :send_invoice do
      transitions from: :pending, to: :paid
      transitions from: :live, to: :live
    end

    event :put_live, after: :send_live_information do
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

  def payment_reference
    "#{model_name.singular}_#{id}_#{created_at.strftime('%y%m')}"
  end

  private

  def send_booking_confirmation
    AdminMailer.new_zuckerl(self).deliver_later
    Zuckerl::BookingConfirmationJob.perform_later self
  end

  def send_invoice
    Zuckerl::InvoiceJob.perform_later self
  end

  def send_live_information
    Zuckerl::LiveInformationJob.perform_later self
  end
end

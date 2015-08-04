class LocationOwnership < ActiveRecord::Base
  # scopes
  #scope :all_pending, -> { where(state: [states[:pending], states[:requested]]) }
  
  # associations
  belongs_to :user
  belongs_to :location

  # states
  # include AASM
  # enum state: { pending: 0, requested: 1, approved: 2, rejected: 3 }
  # aasm column: :state do
  #   state :pending, initial: true
  #   state :requested
  #   state :approved
  #   state :rejected

  #   event :approve, after: :notify_user do
  #     transitions from: :pending, to: :approved, guard: :location_approved?
  #     transitions from: :requested, to: :approved, guard: :location_approved?
  #   end
  # end

  # private

  #   def notify_user    
  #   end

  #   def location_approved?
  #     location.managed?
  #   end
end

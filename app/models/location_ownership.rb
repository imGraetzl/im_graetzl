class LocationOwnership < ActiveRecord::Base
  # scopes
  scope :all_pending, -> { where(state: [states[:pending], states[:requested]]) }
  
  # associations
  belongs_to :user
  belongs_to :location

  # states
  include AASM
  enum state: { pending: 0, requested: 1, approved: 2, rejected: 3 }
  aasm column: :state do
    state :pending, initial: true
    state :requested
    state :approved
    state :rejected

    event :approve, after: :notify_user do
      transitions from: :pending, to: :approved, guard: :location_approved?
      transitions from: :requested, to: :approved, guard: :location_approved?
    end

    # event :request do
    #   transitions from: :basic, to: :requested
    # end

    # event :adopt do
    #   transitions from: :basic, to: :pending
    # end

    # event :approve do
    #   transitions from: :pending, to: :managed
    #   transitions from: :requested, to: :managed
    # end

    # event :adopt do
    #   transitions from: :basic, to: :pending, after: :notify_user
    # end

    # event :approve do
    #   transitions from: :pending, to: :approved, after: :notify_user
    # end
  end

  private

    def notify_user    
    end

    def location_approved?
      location.managed?
    end
end

module Bookables
  class CancellationPolicy < ApplicationRecord
    self.table_name = "bookables_cancellation_policies"

    validates :key, presence: true, uniqueness: true
    validates :name, presence: true
    validates :rules, presence: true

    def refund_tiers
      Array(rules["refund_tiers"])
    end

    def provider_rules
      Array(rules["provider_rules"])
    end

    def customer_rules
      Array(rules["customer_rules"])
    end
  end
end

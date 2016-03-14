module DistrictContext
  extend ActiveSupport::Concern

  included do
    def self.controller_name
      'districts'
    end
  end
end

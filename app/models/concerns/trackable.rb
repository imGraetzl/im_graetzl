module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :trackable
  end

  def create_activity(*args)
    options = args.extract_options!
    options[:key] = "#{self.class.name.demodulize.underscore}.#{args.first}"
    self.activities.create options
  end
end

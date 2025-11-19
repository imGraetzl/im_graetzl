# frozen_string_literal: true

# -----------------------------------------
#   Seeds nur in Development & Staging
# -----------------------------------------
unless Rails.env.production?
  require_relative "seeds/bookables"
end

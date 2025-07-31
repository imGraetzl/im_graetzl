module SchemaOrg
  class Base
    include SchemaOrg::References
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::AssetUrlHelper
    include ActionView::Helpers::SanitizeHelper

    attr_reader :object, :host

    def initialize(object, host:)
      @object = object
      @host = host
    end
  end
end

# Shared methods for ActiveAdmin resources
module SharedAdmin
  extend ActiveSupport::Concern

  def self.included(base)
    # Shared action_item (use 'send' due to 'action_item' is a private method)
    base.send(:action_item, :view_in_app, only: :show, if: proc{resource.graetzl}) do
      link_to 'Im Grätzl ansehen', [resource.graetzl, resource]
    end
  end
end
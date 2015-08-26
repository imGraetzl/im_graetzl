# Sets graetzl for nested route calls
module GraetzlNesting
  extend ActiveSupport::Concern

  included do
    before_action :set_graetzl, only: [:index, :show]
  end

  def assert_graetzl
    @graetzl = Graetzl.find(params[:graetzl_id]) if params[:graetzl_id].present?
    @graetzl ||= current_user.graetzl
  end

  private  

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end
end
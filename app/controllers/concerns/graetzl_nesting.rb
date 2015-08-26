# Sets graetzl for nested route calls
module GraetzlNesting
  extend ActiveSupport::Concern

  included do
    before_action :set_graetzl, only: [:index, :show]
  end

  private  

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end
end
# Sets graetzl for nested route calls
module GraetzlChild
  extend ActiveSupport::Concern

  included do
    before_action :set_graetzl, only: [:index, :show]
  end

  def verify_graetzl_child(child)
    redirect_to [child.graetzl, child] if @graetzl != child.graetzl    
  end

  private  

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end
end
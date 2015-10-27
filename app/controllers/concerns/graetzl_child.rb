# Sets graetzl for nested route calls
module GraetzlChild
  extend ActiveSupport::Concern

  included do
    before_action :set_graetzl, only: [:index, :show]
    before_action :set_map_data, only: [:index]
  end

  def verify_graetzl_child(child)
    redirect_to [child.graetzl, child] if @graetzl != child.graetzl
  end

  private

  def set_graetzl
    @graetzl = Graetzl.find(params[:graetzl_id])
  end

  def set_map_data
    @map_data = GeoJSONService.call(graetzls: @graetzl)
  end
end

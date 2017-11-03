namespace :db do
  desc 'connect districts and graetzls using geometry'
  task connect_districts_graetzls: :environment do
    DistrictGraetzl.delete_all
    District.all.each do |district|
      district.graetzls = Graetzl.where('ST_INTERSECTS(area, :district)', district: district.area)
    end
  end
end

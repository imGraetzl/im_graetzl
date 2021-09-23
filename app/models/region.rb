class Region
  attr_reader :id, :name
  # (Maybe PLZ Range: The first two digits of the zip code)

  DATA = JSON.parse(File.read("#{Rails.root}/config/regions.json"), symbolize_names: true)

  def self.all
    @regions ||= DATA.map{|id, data| new(id, data) }
  end

  def self.get(id)
    all.find{|r| r.id == id }
  end

  def initialize(id, data)
    @id = id.to_s
    @name = data[:name]
    @area_coordinates = data[:area]
    @bound_coordinates = data[:bounds]
    @use_districts = data[:use_districts]
    @zuckerl_graetzl_price = data[:zuckerl_graetzl_price]
    @zuckerl_entire_region_price = data[:zuckerl_entire_region_price]
  end

  def to_s
    name
  end

  def use_districts?
    @use_districts
  end

  def area
    {
      "features": [
        {
          "type": "Feature",
          "geometry": { "coordinates": @area_coordinates, "type": "Polygon" },
        }
      ]
    }
  end

  def bounds
    @bound_coordinates
  end

  def zuckerl_graetzl_price
    @zuckerl_graetzl_price.to_f
  end

  def zuckerl_entire_region_price
    @zuckerl_entire_region_price.to_f
  end

  def platform_name
    if id == 'wien'
      'imGrätzl.at'
    else
      'WeLocally.at'
    end
  end

  def host
    if id == 'wien'
      Rails.application.config.imgraetzl_host
    else
      "#{id}.#{Rails.application.config.welocally_host}"
    end
  end

  def email_host
    if id == 'wien'
      Rails.application.config.imgraetzl_host
    else
      Rails.application.config.welocally_host
    end
  end

  def districts
    return [] if !use_districts?
    @districts ||= District.all_memoized.values.select{|d| d.region_id == id }
  end

  def graetzls
    @graetzls ||= Graetzl.all_memoized.values.select{|g| g.region_id == id }
  end

end

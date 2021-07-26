class Region
  attr_reader :id, :name, :use_districts
  # (Maybe PLZ Range: The first two digits of the zip code)

  def initialize(id, name, use_districts)
    @id = id
    @name = name
    @use_districts = use_districts
  end

  def self.all
    @regions ||= [
      new('wien', 'Wien', true),
      new('kaernten', 'Unterkärnten', false),
    ]
  end

  def self.get(id)
    all.find{|r| r.id == id }
  end

  def use_districts?
    @use_districts
  end

  def to_s
    name
  end

  def host
    if id == 'wien'
      Rails.application.config.imgraetzl_host
    else
      "#{id}.#{Rails.application.config.welocally_host}"
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

class Region
  REGION_LIST = {
    'wien' => ['Wien', true, 'imgraetzl.at'],
    'kaernten' => ['Unterkärnten', false, 'kaernten.welocally.at'],
  }

  attr_reader :id, :name, :use_districts, :domain
  # (Maybe PLZ Range: The first two digits of the zip code)

  def self.get(id)
    if REGION_LIST.key?(id)
      new(id, *REGION_LIST[id])
    end
  end

  def initialize(id, name, use_districts, domain)
    @id = id
    @name = name
    @use_districts = use_districts
    @domain = domain
  end

  def use_districts?
    @use_districts
  end

  def to_s
    name
  end

  def districts
    return [] if !use_districts?
    @districts ||= District.all_memoized.values.select{|d| d.region_id == id }
  end

  def graetzls
    @graetzls ||= Graetzl.all_memoized.values.select{|g| g.region_id == id }
  end

end

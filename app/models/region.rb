class Region
  REGION_LIST = {
    'wien' => ['Wien', true],
    'kaernten' => ['Unterkärnten', false],
  }

  attr_reader :id, :name, :use_districts
  # (Maybe PLZ Range: The first two digits of the zip code)

  def self.get(id)
    if REGION_LIST.key?(id)
      new(id, *REGION_LIST[id])
    end
  end

  def initialize(id, name, use_districts)
    @id = id
    @name = name
    @use_districts = use_districts
  end

  def to_s
    name
  end

end

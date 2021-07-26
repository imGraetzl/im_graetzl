class Region
  attr_reader :id, :name, :use_districts
  # (Maybe PLZ Range: The first two digits of the zip code)

  def initialize(id, name, use_districts)
    @id = id
    @name = name
    @use_districts = use_districts
    @domain = domain
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
    if Rails.env.production?
      prefix = ""
    elsif Rails.env.staging?
      prefix = "staging."
    else
      prefix = "local."
    end

    if id == 'wien'
      "#{prefix}imgraetzl.at"
    else
      "#{prefix}#{id}.welocally.at"
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

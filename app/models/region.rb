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
    @proximity = data[:proximity]
    @use_districts = data[:use_districts]
    @use_subscription = data[:use_subscription]
    @subscription_goal = data[:subscription_goal]
    @zuckerl_graetzl_price = data[:zuckerl][:graetzl][:price]
    @zuckerl_region_price = data[:zuckerl][:region][:price]
    @zuckerl_graetzl_discount_price = data[:zuckerl][:graetzl][:discount_price] if data[:zuckerl][:graetzl][:discount_price]
    @zuckerl_region_discount_price = data[:zuckerl][:region][:discount_price] if data[:zuckerl][:region][:discount_price]
    @room_booster_price = data[:room_booster_price]
    @public_group_id = data[:public_group_id]
    @use_energieteiler = data[:navigation][:energieteiler]
    @wow = data[:wow]
  end

  def to_s
    name
  end

  def use_districts?
    @use_districts
  end

  def use_subscription?
    @use_subscription
  end

  def use_room_pusher?
    room_booster_price > 0
  end

  def use_energieteiler?
    @use_energieteiler
  end

  def hot_august?
    self.is?('wien') && Date.today.to_datetime.between?('2024-08-01', '2024-08-31')
  end

  def crowdfunding_call?
    Date.today.to_datetime.between?('2024-08-29', '2024-09-22')
  end

  def is?(region_id)
    region_id == id ? true : false
  end

  def subscription_goal
    @subscription_goal
  end

  def area
    @area_coordinates
  end

  def proximity
    @proximity
  end

  def bounds
    @bound_coordinates
  end

  def zuckerl_graetzl_price
    self.hot_august? && @zuckerl_graetzl_discount_price ? @zuckerl_graetzl_discount_price.to_f : @zuckerl_graetzl_price.to_f
  end

  def zuckerl_region_price
    self.hot_august? && @zuckerl_region_discount_price ? @zuckerl_region_discount_price.to_f : @zuckerl_region_price.to_f
  end

  def zuckerl_graetzl_old_price
    self.hot_august? && @zuckerl_graetzl_discount_price ? @zuckerl_graetzl_price.to_f : false
  end

  def zuckerl_region_old_price
    self.hot_august? && @zuckerl_region_discount_price ? @zuckerl_region_price.to_f : false
  end

  def room_booster_price
    @room_booster_price.to_f
  end

  def public_group_id
    @public_group_id
  end

  def wow
    @wow
  end

  def wow?
    @wow.present?
    #@wow.present? && @wow.any? { |w| w[:starts_at].to_date < Date.today && w[:ends_at].to_date > Date.today }
  end

  def default_crowd_boost_id
    Rails.env.staging? ? 2 : 1
  end

  def host_id
    if id == 'wien'
      'imgraetzl'
    else
      'welocally'
    end
  end

  def host_domain_name
    if id == 'wien'
      'imGrätzl.at'
    else
      'WeLocally.at'
    end
  end

  def host_domain
    if id == 'wien'
      'imgraetzl.at'
    else
      'welocally.at'
    end
  end

  def host
    if id == 'wien'
      Rails.application.config.imgraetzl_host
    else
      "#{id}.#{Rails.application.config.welocally_host}"
    end
  end

  def domain
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

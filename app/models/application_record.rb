class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.string_enum(enum_options)
    name, values = enum_options.first
    enum_options[name] = values.to_h{|k| [k, k.to_s]}
    enum(enum_options)
  end

  def self.in(region)
    where(region_id: region.id)
  end

  def region
    @region ||= Region.get(region_id)
  end

end

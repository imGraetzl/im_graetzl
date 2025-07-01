class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.string_enum(enum_options)
    name, values = enum_options.first
    raise ArgumentError, "Enum values for #{name} must not be empty! (#{self.name})" if values.empty?
    enum_hash = values.each_with_index.to_h { |k, idx| [k.to_sym, idx] }
    enum(name => enum_hash)
  end

  def self.in(region)
    where(region_id: region.id)
  end

  def region
    @region ||= Region.get(region_id)
  end

end

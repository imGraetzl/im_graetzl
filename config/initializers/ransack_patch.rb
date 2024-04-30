# config/initializers/ransack_patch.rb
# See: https://gorails.com/blog/patching-models-for-ransack-4-0-0-extending-activerecord-for-gem-compatibility

module RansackPatch
  def ransackable_attributes(auth_object = nil)
    authorizable_ransackable_attributes
  end

  def ransackable_associations(auth_object = nil)
    # The method below calls the exact code I had in my initial implementation which is: reflect_on_all_associations.map { |a| a.name.to_s }
    authorizable_ransackable_associations
  end
end

ActiveSupport.on_load(:active_record) do
  extend RansackPatch
end
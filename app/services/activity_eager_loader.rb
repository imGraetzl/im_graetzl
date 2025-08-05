class ActivityEagerLoader
  def self.eager_load_children_and_subjects(activities)
    # Child-Preloads
    activities.group_by(&:child_type).each do |type, acts|
      ids = acts.map(&:child_id).compact
      next if ids.empty?

      model = type.safe_constantize
      model.include_for_box.where(id: ids).load if model && model.respond_to?(:include_for_box)
    end

    # Subject-Preloads
    activities.group_by(&:subject_type).each do |type, acts|
      ids = acts.map(&:subject_id).compact
      next if ids.empty?

      model = type.safe_constantize
      model.include_for_box.where(id: ids).load if model && model.respond_to?(:include_for_box)
    end
  end
end
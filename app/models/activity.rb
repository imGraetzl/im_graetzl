class Activity < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :child, optional: true, polymorphic: true

  has_many :activity_graetzls
  has_many :graetzls, through: :activity_graetzls

  def self.add_public(subject, child = nil, to:)
    if to == :entire_region
      graetzls, entire_region = subject.region.graetzls, true
    else
      graetzls, entire_region = Array(to), false
    end

    where(subject: subject).destroy_all
    activity = create!(
      subject: subject,
      child: child,
      entire_region: entire_region,
      region_id: subject.region_id,
    )
    ActivityGraetzl.import([:activity_id, :graetzl_id], graetzls.map{|g| [activity.id, g.id]})
  end

  def self.add_personal(subject, child = nil, group:)
    where(subject: subject).destroy_all
    create!(
      subject: subject,
      child: child,
      group_id: group.id,
      region_id: subject.region_id,
    )
    ActivityGraetzl.import([:activity_id, :graetzl_id], group.graetzls.map{|g| [activity.id, g.id]})
  end


end

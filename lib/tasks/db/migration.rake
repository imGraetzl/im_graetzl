namespace :db do
  desc 'Populate locations last activity'
  task populate_locations_last_activity: :environment do
    Location.find_each do |location|
      last_activity_at = ([location.created_at] + location.posts.pluck(:created_at) + location.meetings.pluck(:created_at)).max
      location.update_columns(last_activity_at: last_activity_at)
    end
  end
end

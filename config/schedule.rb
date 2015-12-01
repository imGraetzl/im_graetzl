# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :output, 'log/cron.log'

every 1.day, at: '0:00 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake db:truncate"
end

every 1.day, at: '1:00 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake sitemap:refresh:no_ping"
end

every 1.day, at: '2:00 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake db:backup"
end

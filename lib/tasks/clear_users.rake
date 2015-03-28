desc "clear users table"
task :clear_users => :environment do
  User.destroy_all
end
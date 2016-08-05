require 'fileutils'

namespace :admin do
  desc 'Clean up temporary files in the application directory'
  task :cleanup do
    p "Rake admin:cleanup start at: #{Time.now}"
    tmp_files = Dir.glob("#{Rails.root}/{*.png,*.jpeg,*.jpg,*.gif,*.JPG,open-uri*,RackMultipart*}")
    p FileUtils.rm_f tmp_files
  end

  desc 'Renew permissions on cache files'
  task :renew_permissions do
    p "Rake admin:renew_permissions start at: #{Time.now}"
    tmp_dir = Dir.glob "#{Rails.root}/tmp/"
    p FileUtils.chmod_R 0777, tmp_dir
  end
end

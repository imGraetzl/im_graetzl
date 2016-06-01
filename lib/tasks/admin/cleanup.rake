require 'fileutils'

namespace :admin do
  desc 'Clean up temporary files in the application directory'
  task :cleanup do
    p "Rake admin:cleanup start at: #{Time.now}"
    tmp_files = Dir.glob("#{Rails.root}/{*.png,*.jpeg,*.jpg,*.gif,*.JPG,open-uri*}")
    p FileUtils.rm_f tmp_files
  end
end

namespace :eb do
  desc 'Housekeeping for obsolete App versions'
  task truncate: :environment do
    puts "Rake eb:truncate start at: #{Time.now}"
    puts "Rake db:truncate delete old app versions at: #{Time.now}"
    Aws.config[:credentials] = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY'])
    Aws.config[:region] = 'eu-central-1'

    begin
      eb = Aws::ElasticBeanstalk::Client.new
      # get running versions
      response = eb.describe_environments({application_name: 'im_graetzl'})
      running_versions = response.environments.map{|e| e.version_label}

      # get versions to remove
      versions_to_remove = []
      response = eb.describe_application_versions({application_name: 'im_graetzl'})
      response.application_versions.each do |a|
        unless running_versions.include? a.version_label
          versions_to_remove << a
        end
      end

      # keep last 10 versions
      versions_to_remove = versions_to_remove.drop(10)

      # remove versions
      versions_to_remove.each do |v|
        puts "Rake db:truncate delete version: #{v.version_label} at: #{Time.now}"
        begin
          eb.delete_application_version({
            application_name: 'im_graetzl',
            version_label: v.version_label,
            delete_source_bundle: true,
          })
        rescue Aws::ElasticBeanstalk::Errors::ServiceError => e
          puts "Rake db:truncate error: #{e.message} at:#{Time.now}"
        end
      end
    rescue Aws::ElasticBeanstalk::Errors::ServiceError => e
      # rescues all errors returned by AWS Elastic Beanstalk
      puts "Rake db:truncate error in aws eb api: #{e.message} at:#{Time.now}"
    end
  end
end

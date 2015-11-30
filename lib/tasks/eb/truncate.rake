namespace :eb do
  desc 'Housekeeping for obsolete App versions'
  task truncate: :environment do
    Rails.logger.info 'AWS Delete old app versions'
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
        Rails.logger.info "Delete version #{v.version_label}"
        begin
          eb.delete_application_version({
            application_name: 'im_graetzl',
            version_label: v.version_label,
            delete_source_bundle: true,
          })
        rescue Aws::ElasticBeanstalk::Errors::ServiceError => e
          Rails.logger.error e.message
          puts e.message
        end
      end
    rescue Aws::ElasticBeanstalk::Errors::ServiceError => e
      # rescues all errors returned by AWS Elastic Beanstalk
      Rails.logger.error 'Error in AWS Elastic Beanstalk API'
      Rails.logger.error e.message
    end
  end
end

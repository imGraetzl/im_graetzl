namespace :eb do
  desc 'Housekeeping for obsolete App versions'
  task truncate: :environment do
    Rails.logger.info 'Delete old app versions'
    Aws.config[:credentials] = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY'])
    Aws.config[:region] = 'eu-central-1'

    begin
      eb = Aws::ElasticBeanstalk::Client.new
      # get running versions
      resp = eb.describe_environments({application_name: 'im_graetzl'})
      running_versions = resp.environments.map{|e| e.version_label}

      # get versions to remove
      versions_to_remove = []
      resp = eb.describe_application_versions({application_name: 'im_graetzl'})
      resp.application_versions.each do |a|
        unless running_versions.include? a.version_label
          versions_to_remove << a
        end
      end

      # keep last 5 versions
      versions_to_remove = versions_to_remove.drop(5)

      # remove versions
      versions_to_remove.each do |v|
        client.delete_application_version({
          application_name: 'im_graetzl', # required
          version_label: v.version_label, # required
          delete_source_bundle: true,
        })
      end
    rescue Aws::ElasticBeanstalk::Errors::ServiceError
      # rescues all errors returned by AWS Elastic Beanstalk
      Rails.logger.info 'Error in AWS Elastic Beanstalk API'
    end
  end
end

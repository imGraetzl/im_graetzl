namespace :db do
  desc 'Create backup db dump'
  task backup: :environment do
    puts 'Backup database to pg_dump'
    dump = Tempfile.new('dump')
    dump_cmd = "PGPASSWORD=#{ENV['DB_PASSWORD']} pg_dumpall -h #{ENV['DB_HOST']} -U #{ENV['DB_USERNAME']} -p #{ENV['DB_PORT']} > #{dump.path}"
    puts dump_cmd
    #puts `#{dump_cmd}`
    exec dump_cmd
    Aws.config[:credentials] = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY'])
    Aws.config[:region] = 'eu-central-1'
    s3 = Aws::S3::Resource.new
    s3.bucket('im-graetzl-db-backups').object("#{ENV['DB_NAME']}_#{Time.now.strftime("%d-%m-%Y-%H:%M")}").upload_file(dump.path)
  end
end

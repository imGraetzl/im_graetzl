namespace :shrine do
  desc "Löscht alte Dateien aus shrine/cache/ auf S3 (älter als 7 Tage)"
  task clean_cache: :environment do
    require 'aws-sdk-s3'

    bucket_name  = ENV.fetch('UPLOADS_BUCKET')
    region       = ENV.fetch('AWS_REGION')
    prefix       = 'shrine/cache/'
    cutoff_time  = Time.now - 7.days

    logger = Rails.logger
    logger.info "[Shrine::Cleanup] Starte Bereinigung von #{bucket_name}/#{prefix}"
    logger.info "[Shrine::Cleanup] Lösche Dateien älter als #{cutoff_time.utc}"

    s3 = Aws::S3::Client.new(region: region)
    deleted_count = 0
    deleted_total_size = 0

    s3.list_objects_v2(bucket: bucket_name, prefix: prefix).each do |response|
      response.contents.each do |object|
        if object.last_modified < cutoff_time
          s3.delete_object(bucket: bucket_name, key: object.key)
          deleted_count += 1
          deleted_total_size += object.size
        end
      end
    end

    logger.info "[Shrine::Cleanup] Bereinigung abgeschlossen"
    logger.info "[Shrine::Cleanup] Dateien gelöscht: #{deleted_count}"
    logger.info "[Shrine::Cleanup] Gesamtgröße gelöscht: #{(deleted_total_size.to_f / 1024 / 1024).round(2)} MB"

    # Speicherverbrauch nach dem Cleanup:
    total_files = 0
    total_bytes = 0

    continuation_token = nil
    loop do
      response = s3.list_objects_v2(bucket: bucket_name, prefix: prefix, continuation_token: continuation_token)
      response.contents.each do |object|
        total_files += 1
        total_bytes += object.size
      end
      break unless response.is_truncated
      continuation_token = response.next_continuation_token
    end

    logger.info "[Shrine::Cleanup] Aktueller shrine/cache/ Speicher: #{total_files} Dateien, #{(total_bytes.to_f / 1024 / 1024).round(2)} MB"
  end
end

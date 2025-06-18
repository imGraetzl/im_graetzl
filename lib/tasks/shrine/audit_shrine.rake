namespace :shrine do
  desc "Audit orphaned files in shrine/store"
  task audit_shrine: :environment do
    require "aws-sdk-s3"
    require "set"

    bucket_name = ENV.fetch("UPLOADS_BUCKET")
    region      = ENV.fetch("AWS_REGION")
    prefix      = "shrine/store/"

    logger = Rails.logger
    logger.info "[Shrine::Audit] Audit gestartet für: #{bucket_name}/#{prefix}"

    s3 = Aws::S3::Client.new(region: region)
    s3_file_ids = []

    # 1. S3-Dateien sammeln
    s3.list_objects_v2(bucket: bucket_name, prefix: prefix).each do |response|
      response.contents.each do |object|
        id = object.key.delete_prefix(prefix)
        s3_file_ids << id
      end
    end

    logger.info "[Shrine::Audit] S3-Dateien geladen: #{s3_file_ids.size}"

    # 2. Referenzierte IDs sammeln
    referenced_ids = Set.new

    models = {
      CoopDemandCategory: [:main_photo],
      CoopDemand: [:avatar],
      CrowdBoost: [:avatar],
      CrowdCampaign: [:avatar, :cover_photo],
      CrowdCategory: [:main_photo],
      CrowdReward: [:avatar],
      EnergyCategory: [:main_photo],
      EnergyDemand: [:avatar],
      EnergyOffer: [:avatar, :cover_photo],
      EventCategory: [:main_photo],
      Group: [:cover_photo],
      Image: [:file],
      LocationCategory: [:main_photo],
      Location: [:avatar, :cover_photo],
      Meeting: [:cover_photo],
      Poll: [:cover_photo],
      RoomCategory: [:main_photo],
      RoomDemand: [:avatar],
      RoomOffer: [:avatar, :cover_photo],
      User: [:avatar, :cover_photo],
      Zuckerl: [:cover_photo]
    }

    models.each do |model_name, fields|
      model = model_name.to_s.constantize
      fields.each do |field|
        model.where.not("#{field}_data": nil).find_each(batch_size: 500) do |record|
          data = record.send("#{field}_data")
          next unless data.is_a?(Hash)

          referenced_ids << data["id"] if data["id"]

          derivatives = data["derivatives"]
          if derivatives
            derivatives.each_value do |val|
              if val.is_a?(Hash)
                val.each_value { |d| referenced_ids << d["id"] if d["id"] }
              else
                referenced_ids << val["id"] if val["id"]
              end
            end
          end
        end
      end
    end

    logger.info "[Shrine::Audit] Referenzen aus DB geladen: #{referenced_ids.size}"

    # 3. Vergleich
    orphaned_ids = s3_file_ids - referenced_ids.to_a
    logger.warn "[Shrine::Audit] Verwaiste Dateien gefunden: #{orphaned_ids.size}"
    orphaned_ids.take(10).each { |id| logger.warn "[Shrine::Audit] - #{id}" }
    logger.warn "[Shrine::Audit] ... (nur erste 10 angezeigt)" if orphaned_ids.size > 10

    # 4. Speichergröße berechnen
    total_size = 0
    s3.list_objects_v2(bucket: bucket_name, prefix: prefix).each do |response|
      response.contents.each do |object|
        id = object.key.delete_prefix(prefix)
        total_size += object.size if orphaned_ids.include?(id)
      end
    end

    logger.info "[Shrine::Audit] Speicherbedarf der verwaisten Dateien: #{(total_size.to_f / 1024 / 1024).round(2)} MB"
    logger.info "[Shrine::Audit] Dry-run abgeschlossen – keine Datei gelöscht."
  end
end

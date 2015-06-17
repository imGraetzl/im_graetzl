# encoding: utf-8

class CoverPhotoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:

  # hooks
  after :remove, :delete_empty_upload_dirs

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    'cover_photo/' + [version_name, 'default.jpg'].compact.join('_')
    #'https://placeimg.com/900/500/people'
  end

  # Process files as they are uploaded:
  process resize_to_fill: [1960, 740]

  # Create different versions of your uploaded files:
  version :small do
    process resize_to_fill: [980, 370]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  private

    def delete_empty_upload_dirs
      path = ::File.expand_path(store_dir, root)
      Dir.delete(path) # fails if path not empty dir
    rescue SystemCallError
      true # nothing, the dir is not empty
    end

end

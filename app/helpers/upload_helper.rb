module UploadHelper

  def upload_image_input(f, field_name, multiple: false, live_preview: true)
    content_tag(:div, class: 'upload-container') do
      concat f.file_field(field_name, multiple: multiple, class: 'direct-upload-input',
        accept: ImageUploader::ALLOWED_TYPES.join(","),
        data: { upload_server: Rails.application.config.upload_server }
      )

      if multiple
        images_count = f.object.public_send(field_name).size
        concat f.hidden_field(field_name,
          name: "#{f.object_name}[#{field_name}_attributes][#{images_count}][file]",
          value: nil, id: nil,
          class: 'direct-upload-result',
          data: { index: images_count },
        )
      else
        concat f.hidden_field(field_name,
          value: f.object.public_send(:"cached_#{field_name}_data"),
          class: 'direct-upload-result'
        )
      end

      if f.object.public_send(field_name).present? || live_preview
        concat(content_tag(:div, class: "upload-previews #{field_name} #{f.object.class.name.downcase} #{f.object.public_send(field_name).present? ? 'show-hint' : ''}") do
          multiple ? uploaded_images_edit(f, field_name) : uploaded_image_edit(f, field_name)
        end)
        if field_name.to_s == 'cover_photo'
          concat(content_tag(:small, 'Info: Dein Bild wird wie oberhalb dargestellt zugeschnitten. Wähle ein längliches Bild-Format (ca. 980 x 400 Pixel) sollte es nicht passen.', class: 'img-upload-hint'))
        elsif field_name.to_s == 'avatar'
          concat(content_tag(:small, 'Info: Dein Bild wird wie oberhalb dargestellt quadratrisch zugeschnitten.', class: 'img-upload-hint'))
        end
      end

    end
  end

  def uploaded_image_edit(f, field_name)
    return if !f.object.public_send(field_name)
    content_tag(:div, class: 'upload-preview') do
      concat image_tag(f.object.public_send(field_name).url, class: 'upload-preview-image')
      concat(content_tag(:div, class: 'input-checkbox') do
        f.check_box(:"remove_#{field_name}", class: 'deleteCheckbox') +
        f.label(:"remove_#{field_name}", 'Löschen')
      end)
    end
  end

  def uploaded_images_edit(f, field_name)
    f.fields_for(field_name) do |ff|
      content_tag(:div, class: 'upload-preview') do
        concat image_tag(ff.object.file.url, class: 'upload-preview-image')
        concat ff.hidden_field(:file, value: ff.object.cached_file_data) if ff.object.new_record?
        concat(content_tag(:div, class: 'input-checkbox') do
          ff.check_box(:"_destroy", class: 'deleteCheckbox') +
          ff.label(:_destroy, 'Löschen')
        end)
      end
    end
  end

end

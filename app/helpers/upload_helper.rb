module UploadHelper

  def upload_image_input(f, field_name)
    f.file_field(field_name, class: 'direct-upload-input',
      accept: ImageUploader::ALLOWED_TYPES.join(","),
      data: {
        upload_server: Rails.application.config.upload_server,
        preview_element: "#{field_name}-preview",
        upload_result_element: "#{field_name}-result",
    }) +
    f.hidden_field(field_name, value: f.object.public_send(:"cached_#{field_name}_data"),
      id: "#{field_name}-result"
    ) +
    content_tag(:div, id: "#{field_name}-preview", class: 'upload-preview') do
      if f.object.public_send(field_name)
        image_tag(f.object.public_send(field_name).url) +
        content_tag(:div, class: 'input-checkbox') do
          f.check_box(:"remove_#{field_name}", class: 'deleteCheckbox') +
          f.label(:"remove_#{field_name}", 'Löschen')
        end
      end
    end
  end

  def upload_images_input(f, field_name)
    f.file_field(field_name, multiple: true, class: 'direct-upload-input',
      accept: ImageUploader::ALLOWED_TYPES.join(","),
      data: {
        upload_server: Rails.application.config.upload_server,
        preview_element: "#{field_name}-preview",
        upload_result_name: "#{f.object_name}[#{field_name}_attributes][][file]"
    }) +
    content_tag(:div, id: "#{field_name}-preview", class: 'upload-preview') do
      f.fields_for(field_name) do |ff|
        image_tag(ff.object.file.url) +
        content_tag(:div, class: 'input-checkbox') do
          f.check_box(:"_destroy", class: 'deleteCheckbox') +
          f.label(:_destroy, 'Löschen')
        end
      end
    end
  end

end

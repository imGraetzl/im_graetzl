//= require uppy
//= require components/on_render

APP.components.fileUpload = (function() {

  function init() {
    onRender(function() {
      $('.direct-upload-input').each(function() { setupFileUpload(this); });
    });
  }

  function setupFileUpload(fileInput) {
    const multiple = fileInput.multiple;
    const formGroup = fileInput.parentNode;
    const uppy = fileUpload(fileInput);

    formGroup.removeChild(fileInput)

    uppy.use(Uppy.FileInput, {
      target: formGroup,
      locale: { strings: { chooseFiles: multiple ? 'Choose files' : 'Choose file'} },
    }).use(Uppy.Informer, {
      target: formGroup,
    });

    uppy.on('upload-success', function(file, response) {
      const fileData = uploadedFileData(file, response, fileInput);
      const $form = $(formGroup).parents('form');
      // Append or update hidden field
      if (multiple) {
        const hiddenField = $("<input type='hidden'>").attr("name", fileInput.dataset.uploadResultName).val(fileData);
        $form.append(hiddenField);
      } else {
        $form.find("#" + fileInput.dataset.uploadResultElement).val(fileData);
      }
    });

    if (fileInput.dataset.previewElement) {
      const previewContainer = document.getElementById(fileInput.dataset.previewElement)
      uppy.use(Uppy.ProgressBar, {
        target: previewContainer.parentNode,
      }).use(Uppy.ThumbnailGenerator, {
        thumbnailWidth: 600,
      });

      uppy.on('thumbnail:generated', function(file, preview) {
        // Append or update preview image
        const image = $("<img>").attr("src", preview);
        if (multiple) {
          $(previewContainer).append(image);
        } else {
          if ($(previewContainer).find("img").length) {
            $(previewContainer).find("img").replaceWith(image);
          } else {
            $(previewContainer).append(image);
          }
        }
      });
    }
  }

  function fileUpload(fileInput) {
    const uppy = Uppy.Core({
      id: fileInput.id,
      autoProceed: true,
      restrictions: {
        allowedFileTypes: fileInput.accept.split(','),
      },
    })

    if (fileInput.dataset.uploadServer == 's3') {
      uppy.use(Uppy.AwsS3, {
        companionUrl: '/', // will call Shrine's presign endpoint mounted on `/s3/params`
      })
    } else {
      uppy.use(Uppy.XHRUpload, {
        endpoint: '/upload', // Shrine's upload endpoint
      })
    }

    return uppy;
  }

  function uploadedFileData(file, response, fileInput) {
    if (fileInput.dataset.uploadServer == 's3') {
      const id = file.meta['key'].match(/^cache\/(.+)/)[1]; // object key without prefix

      return JSON.stringify(fileData(file, id))
    } else {
      return JSON.stringify(response.body)
    }
  }

  // constructs uploaded file data in the format that Shrine expects
  function fileData(file, id) {
    return {
      id: id,
      storage: 'cache',
      metadata: {
        size:      file.size,
        filename:  file.name,
        mime_type: file.type,
      }
    };
  }

  return {
    init: init
  };

})();

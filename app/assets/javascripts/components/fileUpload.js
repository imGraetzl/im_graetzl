//= require uppy
//= require components/on_render

APP.components.fileUpload = (function() {

  function init() {
    onRender(function() {
      $('.direct-upload-input').each(function() { setupFileUpload($(this)); });
    });
  }

  function setupFileUpload(fileInput) {
    const uppy = fileUpload(fileInput);
    const multiple = fileInput.attr("multiple");
    const container = fileInput.parents('.upload-container');
    const previewContainer = container.find(".upload-previews");

    fileInput.on('change', function(event) {
      const files = Array.from(event.target.files)
      files.forEach(function(file) {
        uppy.addFile({
          name: file.name,
          type: file.type,
          data: file
        });
      });
    });

    uppy.on('upload-success', function(file, response) {
      const fileData = uploadedFileData(file, response, fileInput);
      const resultField = container.find(".direct-upload-result").last();
      // Append or update hidden field
      if (multiple) {
        resultField.val(fileData);
        container.append(generateNextInput(resultField));
      } else {
        resultField.val(fileData);
      }
      resultField.trigger("upload:complete");
    });

    if (previewContainer.length) {
      uppy.use(Uppy.ThumbnailGenerator, {
        thumbnailWidth: 600,
      });

      uppy.on('thumbnail:generated', function(file, preview) {
        const element = imagePreview(preview);
        if (multiple) {
          previewContainer.append(element);
        } else {
          previewContainer.html(element);
        }
      });
    }
  }

  function fileUpload(fileInput) {
    const uppy = Uppy.Core({
      autoProceed: true,
      restrictions: {
        allowedFileTypes: fileInput.attr("accept").split(','),
      },
    })

    if (fileInput.data("upload-server") == 's3') {
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
    if (fileInput.data("upload-server") == 's3') {
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

  function generateNextInput(lastInput) {
    const input = lastInput.clone().val(null);
    const oldIndex = lastInput.data("index");
    const newIndex = oldIndex + 1;
    input.data("index", newIndex);
    input.attr("name", input.attr("name").replace("[" + oldIndex + "]", "[" + newIndex + "]"));
    return input;
  }

  function imagePreview(preview) {
    const image = $("<img class='upload-preview-image'>").attr("src", preview);
    return $("<div class='upload-preview'></div>").html(image);
  }

  return {
    init: init
  };

})();

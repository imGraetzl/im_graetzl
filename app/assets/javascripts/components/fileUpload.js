//= require uppy
//= require components/on_render

APP.components.fileUpload = (function() {

  function init() {
    onRender(function() {
      $('.direct-upload-input').each(function() { setupFileUpload($(this)); });
    });
  }

  function setupFileUpload(fileInput) {
    if (fileInput.hasClass("uppy-setup")) return;
    var uppy = fileUpload(fileInput);
    var multiple = fileInput.attr("multiple");
    var container = fileInput.parents('.upload-container');
    var previewContainer = container.find(".upload-previews");

    fileInput.on('change', function(event) {
      var files = Array.from(event.target.files)
      files.forEach(function(file) {
        uppy.addFile({
          name: file.name,
          type: file.type,
          data: file
        });
      });
    });

    uppy.on('upload-success', function(file, response) {
      var fileData = uploadedFileData(file, response, fileInput);
      var resultField = container.find(".direct-upload-result").last();

      if (multiple) {
        resultField.val(fileData);
        container.append(generateNextInput(resultField));
      } else {
        resultField.val(fileData);
      }
      resultField.trigger("upload:complete");
    });

    // Don't upload files through file input, they've been directly uploaded
    fileInput.parents("form").on("submit", function() {
      fileInput.val(null);
    });

    if (previewContainer.length) {
      uppy.use(Uppy.ThumbnailGenerator, {
        thumbnailWidth: 600,
      });

      uppy.on('thumbnail:generated', function(file, preview) {
        var element = imagePreview(preview);
        if (multiple) {
          previewContainer.append(element).addClass('show-hint');
        } else {
          previewContainer.html(element).addClass('show-hint');
        }
      });
    }

    fileInput.addClass("uppy-setup");
  }

  function fileUpload(fileInput) {
    var uppy = Uppy.Core({
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
      var id = file.meta['key'].split("/").pop(); // object key without prefix
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
    var input = lastInput.clone().val(null);
    var oldIndex = lastInput.data("index");
    var newIndex = oldIndex + 1;
    input.data("index", newIndex);
    input.attr("name", input.attr("name").replace("[" + oldIndex + "]", "[" + newIndex + "]"));
    return input;
  }

  function imagePreview(preview) {
    var image = $("<img class='upload-preview-image'>").attr("src", preview);
    return $("<div class='upload-preview'></div>").html(image);
  }

  return {
    init: init
  };

})();

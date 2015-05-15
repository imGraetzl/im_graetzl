APP.controllers.meetings = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();
        // APP.components.imgUploadPreview.init();


        $('.datepicker').pickadate({
            formatSubmit: 'yyyy-mm-dd',
            hiddenSuffix: ''
        });

        $('.timepicker').pickatime({
            interval: 15,
            format: 'HH:i',
            formatSubmit: 'HH:i',
            hiddenSuffix: ''
        });

        $('select.categories').SumoSelect({
            placeholder: 'Kategorien wählen',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

        // titleImg
        $(document).on('ready page:load', function() {
            $(".titleImg").css("opacity", 1);
        });




        $('.upload-image').each(function() {

            var $fieldBlock = $(this),
                $field = $fieldBlock.find('input[type=file]'),
                $btnDelete = $fieldBlock.find('[class^=icon-delete]'),
                $deleteCheckbox = $fieldBlock.find('.deleteCheckbox');

            if ($deleteCheckbox.val()) {
                resetLocalImg($fieldBlock);
            }

            if ($field.val()) {
                showLocalImg($fieldBlock);
            }


            $field.on('change', function() {
                if (this.files && this.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (event) {
                        showLocalImg($fieldBlock);
                    };
                    reader.readAsDataURL(this.files[0]);
                }
            });

            $btnDelete.on('click', function() {
                resetLocalImg($fieldBlock);
            });

        })

    }


    function showLocalImg($element) {
        var imgSrc = (event != undefined) ? event.target.result : $element.find('input[type=file]').val();
        console.log(imgSrc);
        $element.find('.imgCrop').remove();
        $element.prepend('<div class="imgCrop"><img src=' + imgSrc +'></div>');
        $element.find('[class^=icon-delete]').show();
        $element.find('.deleteCheckbox').attr('checked', false);
        adjustImg($element.find('img'));
    }

    function resetLocalImg($element) {
        $element.find('.imgCrop').remove();
        $element.find('[class^=icon-delete]').hide();
        $element.find('.deleteCheckbox').attr('checked', true);
        $element.find('input[type=file]').val('');
    }

    function adjustImg($img) {
        // what's the size of this image and it's parent
        var w = $img.width();
        var h = $img.height();
        var tw = $img.parent().width();
        var th = $img.parent().height();

        // compute the new size and offsets
        var result = scaleImg(w, h, tw, th, false);

        // adjust the image coordinates and size
        $img.attr("width", result.width);
        $img.attr("height", result.height);
        $img.css("left", result.targetleft);
        $img.css("top", result.targettop);
    }

    function scaleImg(srcwidth, srcheight, targetwidth, targetheight, fLetterBox) {

        var result = { width: 0, height: 0, fScaleToTargetWidth: true };

        if ((srcwidth <= 0) || (srcheight <= 0) || (targetwidth <= 0) || (targetheight <= 0)) {
            return result;
        }

        // scale to the target width
        var scaleX1 = targetwidth;
        var scaleY1 = (srcheight * targetwidth) / srcwidth;

        // scale to the target height
        var scaleX2 = (srcwidth * targetheight) / srcheight;
        var scaleY2 = targetheight;

        // now figure out which one we should use
        var fScaleOnWidth = (scaleX2 > targetwidth);
        if (fScaleOnWidth) {
            fScaleOnWidth = fLetterBox;
        }
        else {
            fScaleOnWidth = !fLetterBox;
        }

        if (fScaleOnWidth) {
            result.width = Math.floor(scaleX1);
            result.height = Math.floor(scaleY1);
            result.fScaleToTargetWidth = true;
        }
        else {
            result.width = Math.floor(scaleX2);
            result.height = Math.floor(scaleY2);
            result.fScaleToTargetWidth = false;
        }
        result.targetleft = Math.floor((targetwidth - result.width) / 2);
        result.targettop = Math.floor((targetheight - result.height) / 2);

        return result;
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
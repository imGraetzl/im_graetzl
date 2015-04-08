APP.components.formStepSlider = function(spec) {

    var el = spec.el,
        steps = spec.steps,
        slider;

    function init() {

        startCarousell();
        events();

        _.each(steps, function(el) {
            el.init();
        });

    }

    function events() {
        el
            .on("click", ".prev", function() {
                slider.trigger("prev");
            })
            .on("click", ".next", function() {
                var currentStep = $(this).closest("[data-step]").attr("data-step");
                if (validateStep(currentStep)) {
                    slider.trigger("next");
                }
            });
    }

    function startCarousell() {
        slider = el.carouFredSel({
            auto: false,
            circular: false,
            infinite: false,
            responsive: true,
            transition: true,
            scroll: {
                onAfter: function(data) {
                    var currentStep = $(data.items.old).attr("data-step");
                    var newStep = $(data.items.visible).attr("data-step");
                    onStepChanged(currentStep, newStep);
                }
            }
        });
    }

    function onStepChanged(currentStep, newStep) {
        if (_.isObject(steps[currentStep]) && _.isFunction(steps[currentStep].onExit)) {
            steps[currentStep].onExit();
        }
        if (_.isObject(steps[newStep]) && _.isFunction(steps[newStep].onExit)) {
            steps[newStep].onEnter();
        }
    }

    function validateStep(step) {
        if (_.isObject(steps[step]) && _.isFunction(steps[step].validate)) {
            return steps[step].validate();
        } else {
            return true;
        }
    }

    function gotoSlide(slide) {
        slider.trigger("slideTo",  $("[data-step=" + slide + "]"));
    }


    init();


    return {
        slider: slider
    }

};

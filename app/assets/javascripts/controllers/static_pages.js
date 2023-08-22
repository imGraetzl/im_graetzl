APP.controllers.static_pages = (function() {

function init() {
  if($(".-about-pages").exists()) initAboutPages();
  if($(".-mentoring-page").exists()) initMentoring();
  if($(".good-morning-dates").exists()) initGoodMorningDates();
  if($(".balkonsolar-page").exists()) initBalkonSolar();
  if($(".energieteiler").exists()) initEnergieteiler();
  if($(".popup-page").exists()) initPopUp();
  if($("#help_nav").exists()) initHelpScroller();
}

function initGoodMorningDates() {
  if ($('.cards-filter').exists()) {
    APP.components.cardBoxFilter.init();
  }
}

function initBalkonSolar() {
  if ($('.cards-filter').exists()) {
    APP.components.cardBoxFilter.init();
  }
}

function initPopUp() {
  if ($('.cards-filter').exists()) {
    APP.components.cardBoxFilter.init();
  }
}

function initEnergieteiler() {
  if ($('.cards-filter').exists()) {
    APP.components.cardBoxFilter.init();
  }
}

function initMentoring() {
  APP.components.initMentoring.init();
}

function initAboutPages() {
  $('.press-view-all').on('click', function(){
    $(this).closest(".presslist").find('.row').addClass('-show');
    $(this).hide();
  });
};

function checkOffset() {
    if($('#help_nav').offset().top + $('#help_nav').height() >= $('.navigation-bar').offset().top )
      $('#help_nav').addClass( "fix_nav" ).removeClass( "float_nav" );
}

function initHelpScroller() {

  var elementPosition = $('#help_nav').offset();
  $(window).scroll(function(){
    if($(window).scrollTop() > elementPosition.top){
      $('#help_nav').addClass( "float_nav" ).removeClass( "fix_nav" );
      checkOffset();
    } else {
        $('#help_nav').removeClass( "fix_nav" ).removeClass( "float_nav" );
    }
  });

  var $sections = $('.container');
  $(window).scroll(function(){

    var currentScroll = $(this).scrollTop();
    var $currentSection

    $sections.each(function(){
      var divPosition = $(this).offset().top;
      if( divPosition - 1 < currentScroll ){
        $currentSection = $(this);
        var id = $currentSection.attr('id');
        $('a').addClass('-mint');
        $('#nav-'+id).removeClass('-mint');
      }
    })
  });


  $('a[href*="#"]')
    // Remove links that don't actually link to anything
    .not('[href="#"]')
    .not('[href="#0"]')
    .click(function(event) {
      if (
        location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '')
        &&
        location.hostname == this.hostname
      ) {
        // Figure out element to scroll to
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
        // Does a scroll target exist?
        if (target.length) {
          // Only prevent default if animation is actually gonna happen
          event.preventDefault();
          $('html, body').animate({
            scrollTop: target.offset().top
          }, 1000, function() {
          });
        }
      }
    });

}

return {
  init: init
}

})();

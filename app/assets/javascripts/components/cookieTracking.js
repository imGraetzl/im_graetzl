APP.components.cookieTracking = (function() {

  function init() {

    // SETUP GTM & ANALYTICS --------------------------------
    var uaid = $("body").attr("data-uaid");
    var userid = $("body").attr("data-userid") || false;

    // LOAD ANALYTICS ASYNC
    var script = document.createElement('script');
    script.src = 'https://www.googletagmanager.com/gtag/js?id=' + uaid;
    script.setAttribute('async', 'async');
    document.head.appendChild(script);

    gtag('set', 'linker', {'domains': ['imgraetzl.at', 'welocally.at']});
    gtag('consent', 'default', {
        'ad_storage': 'denied',
        'analytics_storage': 'granted'
    });
    gtag('js', new Date());
    if (userid) { gtag('set', {'user_id': userid}); }
    gtag('config', uaid, { 'anonymize_ip': true });

    // Set Analytics Permission Status on Load
    if ($.fn.ihavecookies.preference('analytics') === true) {
        gtag('consent', 'update', {
          'analytics_storage': 'granted'
        });
    }

    // Cookie Consent Banner
    var eventSubmitted = false;
    var cookieOptions = {
        title: 'Cookie Informationen',
        message: 'Wir kommen fast ohne Cookies aus. Es gibt dennoch Cookies, für die wir deine Zustimmung benötigen.',
        delay: 500,
        expires: 90,
        link: '/info/datenschutz',
        uncheckBoxes: false,
        acceptBtnLabel: 'Cookies akzeptieren',
        advancedBtnLabel: 'Einstellungen',
        moreInfoLabel: 'Weitere Informationen',
        cookieTypesTitle: 'Wähle welche Cookies du zulassen möchtest.',
        fixedCookieTypeLabel: 'Notwendige',
        fixedCookieTypeDesc: 'Notwendige Cookies damit die Website funktioniert.',
        cookieTypes: [
          {
            type: 'Analytics',
            value: 'analytics',
            description: 'Cookies die uns dabei helfen die Website zu verbessern.'
          },
        ],
        onAccept: function(){

            myPreferences = $.fn.ihavecookies.cookie();
            myPreferences = myPreferences.join();
            myPreferences == '' ? myPreferences = 'all denied' : myPreferences;

            // Event Tracking - Update Status
            if (!eventSubmitted) {
              gtag(
                'event', 'Accept', {
                'event_category': 'Consent Manager :: Update',
                'event_label': myPreferences
              });
              eventSubmitted = true;
            }

            // Set Analytics Status
            if ($.fn.ihavecookies.preference('analytics') === true) {
              gtag('consent', 'update', {
                'analytics_storage': 'granted'
              });
            } else {
              gtag('consent', 'update', {
                'analytics_storage': 'denied'
              });
            }
        }
    }

    // Load Consent Manager
    $('body').ihavecookies(cookieOptions);

    // Event-Tracking for Load-Status of Consent Manager
    myPreferences = $.fn.ihavecookies.cookie();
    if (myPreferences) {
      myPreferences == '' ? myPreferences = 'all denied' : myPreferences.join();
      gtag(
        'event', 'Status', {
        'event_category': 'Consent Manager :: Init',
        'event_label': 'cookie :: ' + myPreferences
      });
    } else {
      gtag(
        'event', 'Status', {
        'event_category': 'Consent Manager :: Init',
        'event_label': 'no cookie :: consent manager shown'
      });
    }


    // Button for Opening Consent Manager
    $('#ihavecookiesBtn').on('click', function(){
        $('body').ihavecookies(cookieOptions, 'reinit');
        eventSubmitted = false;
    });

  }

  return {
      init: init
  }

})();

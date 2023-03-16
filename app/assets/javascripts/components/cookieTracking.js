APP.components.cookieTracking = (function() {

  function init() {

    // GLOBAL SETUP VARS --------------------------------
    var uaid = $("body").attr("data-uaid");
    var userid = $("body").attr("data-userid") || false;
    var testmode = false;

    // Set Analytics Permission Status on Load from User Cookie Setting
    if (getCookie('cookieControl') && $.fn.ihavecookies.preference('analytics') === false) {
      gtag('consent', 'default', {
        'ad_storage': 'denied',
        'analytics_storage': 'denied'
      });
      var trackAnalytics = false;
    } else {
      gtag('consent', 'default', {
        'ad_storage': 'denied',
        'analytics_storage': 'granted'
      });
      var trackAnalytics = true;
    }

    // Dev Mode Infos
    if ($("body").attr("data-env-mode") == 'dev') {
      testmode = true;
      console.log('Testmode: ' + testmode);
      console.log('Analytics Permission: ' + $.fn.ihavecookies.preference('analytics'));
      console.log('Analytics Tracking: ' + trackAnalytics);
    }

    // LOAD ANALYTICS ASYNC
    var script = document.createElement('script');
    script.src = 'https://www.googletagmanager.com/gtag/js?id=' + uaid;
    script.setAttribute('async', 'async');
    document.head.appendChild(script);

    // Setup
    gtag('set', 'linker', {'domains': ['imgraetzl.at', 'welocally.at']});
    gtag('js', new Date());
    if (userid) { gtag('set', {'user_id': userid}); }
    gtag('config', uaid, { 'anonymize_ip': true, 'debug_mode': testmode });

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
                'event', `Consent Manager :: Update :: ${myPreferences}`
              );
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
        'event', `Consent Manager :: Init :: ${myPreferences}`
      );
    } else {
      gtag(
        'event', `Consent Manager :: Init :: default`
      );
    }


    // Button for Opening Consent Manager
    $('#ihavecookiesBtn').on('click', function(){
        $('body').ihavecookies(cookieOptions, 'reinit');
        eventSubmitted = false;
    });

    // Helper Function getCookie
    function getCookie(name) {
      const value = `; ${document.cookie}`;
      const parts = value.split(`; ${name}=`);
      if (parts.length === 2) return parts.pop().split(';').shift();
    }

  }

  return {
      init: init
  }

})();

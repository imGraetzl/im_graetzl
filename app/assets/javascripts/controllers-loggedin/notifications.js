APP.controllers_loggedin.notifications = (function() {

  function init() {
    if ($("section.notification-container").exists()) initAdminNotifications();
  }

  function initAdminNotifications() {
    APP.components.cardBoxFilter.init();
  }

  return {
    init: init
  }

})();

APP.controllers.notification_settings = (function() {

  function init() {
    var notfication_types = [
      "new_meeting_in_graetzl",
      "new_post_in_graetzl",
      "initiator_comments",
      "another_user_comments",
      "another_attendee",
      "update_of_meeting",
      "user_comments_users_meeting"
    ];
    jQuery.each(notfication_types, function(index, notification_type) {
      $('#toggle_' + notification_type).click(function() {
        jQuery.post("/users/notification_settings/toggle_website_notification", {
          type: notification_type }).
          done(function(response) {
            $('#toggle_' + notification_type + ' .on').toggle();
            $('#toggle_' + notification_type + ' .off').toggle();
          })
        .fail(function() {
          alert("Etwas ist schief gegangen!");
        });
      }); 
    });
  }



// ---------------------------------------------------------------------- Public

return {
  init: init
}

})();

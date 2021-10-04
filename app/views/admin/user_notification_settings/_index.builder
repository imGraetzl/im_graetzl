context.instance_eval do
  column(:email) { |u| link_to u.email, admin_user_path(u) }
  column("Graetzl") { |u|
    [
      "<span class='mailtype'>New Meeting: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewMeeting)}'>#{u.enabled_mail_notification(Notifications::NewMeeting)}</span>",
      "<span class='mailtype'>New Location: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewLocation)}'>#{u.enabled_mail_notification(Notifications::NewLocation)}</span>",
      "<span class='mailtype'>New Location Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewLocationPost)}'>#{u.enabled_mail_notification(Notifications::NewLocationPost)}</span>",
      "<span class='mailtype'>New Room Offer: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewRoomOffer)}'>#{u.enabled_mail_notification(Notifications::NewRoomOffer)}</span>",
      "<span class='mailtype'>New Room Demand: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewRoomDemand)}'>#{u.enabled_mail_notification(Notifications::NewRoomDemand)}</span>",
      "<span class='mailtype'>New Tool Offer: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewToolOffer)}'>#{u.enabled_mail_notification(Notifications::NewToolOffer)}</span>",
      "<span class='mailtype'>New Coop Demand: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewCoopDemand)}'>#{u.enabled_mail_notification(Notifications::NewCoopDemand)}</span>",
    ].join("<br>").html_safe
  }
  column("Betrifft Mich") { |u|
    [
      "<span class='mailtype'>Commented Content: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentOnOwnedContent)}'>#{u.enabled_mail_notification(Notifications::CommentOnOwnedContent)}</span>",
      "<span class='mailtype'>Also Commented C.: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentOnFollowedContent)}'>#{u.enabled_mail_notification(Notifications::CommentOnFollowedContent)}</span>",
      "<span class='mailtype'>Commented Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::ReplyOnComment)}'>#{u.enabled_mail_notification(Notifications::ReplyOnComment)}</span>",
      "<span class='mailtype'>Also Commented Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::ReplyOnFollowedComment)}'>#{u.enabled_mail_notification(Notifications::ReplyOnFollowedComment)}</span>",
      "<span class='mailtype'>Comment in Meeting: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentInMeeting)}'>#{u.enabled_mail_notification(Notifications::CommentInMeeting)}</span>",
      "<span class='mailtype'>Meeting New Attendee: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::MeetingAttended)}'>#{u.enabled_mail_notification(Notifications::MeetingAttended)}</span>",
      "<span class='mailtype'>Commented Wall: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewWallComment)}'>#{u.enabled_mail_notification(Notifications::NewWallComment)}</span>",
    ].join("<br>").html_safe
  }
  column("Groups") { |u|
    [
      "<span class='mailtype'>New Discussion: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewGroupDiscussion)}'>#{u.enabled_mail_notification(Notifications::NewGroupDiscussion)}</span>",
      "<span class='mailtype'>New Meeting: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewGroupMeeting)}'>#{u.enabled_mail_notification(Notifications::NewGroupMeeting)}</span>",
      "<span class='mailtype'>New Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewGroupPost)}'>#{u.enabled_mail_notification(Notifications::NewGroupPost)}</span>",
    ].join("<br>").html_safe
  }
end

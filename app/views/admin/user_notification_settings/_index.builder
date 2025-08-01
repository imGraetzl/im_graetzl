context.instance_eval do
  column(:email) { |u| link_to u.email, admin_user_path(u) }
  column("Graetzl") { |u|
    [
      "<span class='mailtype'>New Meeting: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewMeeting)}'>#{u.enabled_mail_notification(Notifications::NewMeeting)}</span>",
      "<span class='mailtype'>New Location: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewLocation)}'>#{u.enabled_mail_notification(Notifications::NewLocation)}</span>",
      "<span class='mailtype'>New Location Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewLocationPost)}'>#{u.enabled_mail_notification(Notifications::NewLocationPost)}</span>",
      "<span class='mailtype'>New Location Menu: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewLocationMenu)}'>#{u.enabled_mail_notification(Notifications::NewLocationMenu)}</span>",
      "<span class='mailtype'>New Room Offer: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewRoomOffer)}'>#{u.enabled_mail_notification(Notifications::NewRoomOffer)}</span>",
      "<span class='mailtype'>New Room Demand: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewRoomDemand)}'>#{u.enabled_mail_notification(Notifications::NewRoomDemand)}</span>",
      "<span class='mailtype'>New Energy Offer: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewEnergyOffer)}'>#{u.enabled_mail_notification(Notifications::NewEnergyOffer)}</span>",
      "<span class='mailtype'>New Energy Demand: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewEnergyDemand)}'>#{u.enabled_mail_notification(Notifications::NewEnergyDemand)}</span>",
      "<span class='mailtype'>New Coop Demand: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewCoopDemand)}'>#{u.enabled_mail_notification(Notifications::NewCoopDemand)}</span>",
    ].join("<br>").html_safe
  }
  column("Betrifft Mich") { |u|
    [
      "<span class='mailtype'>New Meeting Attendee: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::MeetingAttended)}'>#{u.enabled_mail_notification(Notifications::MeetingAttended)}</span>",
      "<span class='mailtype'>Commented Content: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentOnOwnedContent)}'>#{u.enabled_mail_notification(Notifications::CommentOnOwnedContent)}</span>",
      "<span class='mailtype'>Commented Campaign: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentOnCrowdCampaign)}'>#{u.enabled_mail_notification(Notifications::CommentOnCrowdCampaign)}</span>",
      "<span class='mailtype'>Commented Followed: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentOnFollowedContent)}'>#{u.enabled_mail_notification(Notifications::CommentOnFollowedContent)}</span>",
      "<span class='mailtype'>Reply On Comment: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::ReplyOnComment)}'>#{u.enabled_mail_notification(Notifications::ReplyOnComment)}</span>",
      "<span class='mailtype'>Reply On Followed: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::ReplyOnFollowedComment)}'>#{u.enabled_mail_notification(Notifications::ReplyOnFollowedComment)}</span>",
      "<span class='mailtype'>Comment in Attending: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::CommentInAttending)}'>#{u.enabled_mail_notification(Notifications::CommentInAttending)}</span>",
      "<span class='mailtype'>Commented Wall: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewWallComment)}'>#{u.enabled_mail_notification(Notifications::NewWallComment)}</span>",
    ].join("<br>").html_safe
  }
  column("Groups") { |u|
    [
      "<span class='mailtype'>New Discussion: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewGroupDiscussion)}'>#{u.enabled_mail_notification(Notifications::NewGroupDiscussion)}</span>",
      "<span class='mailtype'>New Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewGroupPost)}'>#{u.enabled_mail_notification(Notifications::NewGroupPost)}</span>",
      "<span class='mailtype'>New Crowd Campaign: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewCrowdCampaign)}'>#{u.enabled_mail_notification(Notifications::NewCrowdCampaign)}</span>",
      "<span class='mailtype'>New Crowd Post: </span><span class='status_tag #{u.enabled_mail_notification(Notifications::NewCrowdCampaignPost)}'>#{u.enabled_mail_notification(Notifications::NewCrowdCampaignPost)}</span>",
    ].join("<br>").html_safe
  }
end

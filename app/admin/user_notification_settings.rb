ActiveAdmin.register User, as: "User Notification Settings" do
  menu parent: 'Users'

  actions :index
  #config.filters = false

  scope :all, default: true
  scope :business
  scope :admin

  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select' }
  filter :id, label: 'User', as: :select, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :email

  filter :user_mail_setting, as: :select, collection: proc {[
    ['New Meeting - Weekly','weekly_NewMeeting'],['New Meeting - Daily','daily_NewMeeting'],['New Meeting - Immediate','immediate_NewMeeting'],['New Meeting - Off','off_NewMeeting'],
    ['New Location - Weekly','weekly_NewLocation'],['New Location - Daily','daily_NewLocation'],['New Location - Immediate','immediate_NewLocation'],['New Location - Off','off_NewLocation'],
    ['New Location Post - Weekly','weekly_NewLocationPost'],['New Location Post - Daily','daily_NewLocationPost'],['New Location Post - Immediate','immediate_NewLocationPost'],['New Location Post - Off','off_NewLocationPost'],
    ['New Location Menu - Weekly','weekly_NewLocationMenu'],['New Location Menu - Daily','daily_NewLocationMenu'],['New Location Menu - Immediate','immediate_NewLocationMenu'],['New Location Menu - Off','off_NewLocationMenu'],

    ['New RoomOffer - Weekly','weekly_NewRoomOffer'],['New RoomOffer - Daily','daily_NewRoomOffer'],['New RoomOffer - Immediate','immediate_NewRoomOffer'],['New RoomOffer - Off','off_NewRoomOffer'],
    ['New RoomDemand - Weekly','weekly_NewRoomDemand'],['New RoomDemand - Daily','daily_NewRoomDemand'],['New RoomDemand - Immediate','immediate_NewRoomDemand'],['New RoomDemand - Off','off_NewRoomDemand'],

    ['New CoopDemand - Weekly','weekly_NewCoopDemand'],['New CoopDemand - Daily','daily_NewCoopDemand'],['New CoopDemand - Immediate','immediate_NewCoopDemand'],['New CoopDemand - Off','off_NewCoopDemand'],
    ['New ToolOffer - Weekly','weekly_NewToolOffer'],['New ToolOffer - Daily','daily_NewToolOffer'],['New ToolOffer - Immediate','immediate_NewToolOffer'],['New ToolOffer - Off','off_NewToolOffer'],

    ['New CrowdCampaign - Weekly','weekly_NewCrowdCampaign'],['New CrowdCampaign - Daily','daily_NewCrowdCampaign'],['New CrowdCampaign - Immediate','immediate_NewCrowdCampaign'],['New CrowdCampaign - Off','off_NewCrowdCampaign'],
    ['New CrowdCampaignPost - Weekly','weekly_NewCrowdCampaignPost'],['New CrowdCampaignPost - Daily','daily_NewCrowdCampaignPost'],['New CrowdCampaignPost - Immediate','immediate_NewCrowdCampaignPost'],['New CrowdCampaignPost - Off','off_NewCrowdCampaignPost'],

    ['Comment in Meeting - Weekly','weekly_CommentInMeeting'],['Comment in Meeting - Daily','daily_CommentInMeeting'],['Comment in Meeting - Immediate','immediate_CommentInMeeting'],['Comment in Meeting - Off','off_CommentInMeeting'],
    ['New Attendee in Meeting - Weekly','weekly_MeetingAttended'],['New Attendee in Meeting - Daily','daily_MeetingAttended'],['New Attendee in Meeting - Immediate','immediate_MeetingAttended'],['New Attendee in Meeting - Off','off_MeetingAttended'],

    ['Commented Content - Weekly','weekly_CommentOnOwnedContent'],['Commented Content - Daily','daily_CommentOnOwnedContent'],['Commented Content - Immediate','immediate_CommentOnOwnedContent'],['Commented Content - Off','off_CommentOnOwnedContent'],
    ['Also Commented Content - Weekly','weekly_CommentOnFollowedContent'],['Also Commented Content - Daily','daily_CommentOnFollowedContent'],['Also Commented Content - Immediate','immediate_CommentOnFollowedContent'],['Also Commented Content - Off','off_CommentOnFollowedContent'],

    ['Commented on my Post - Weekly','weekly_ReplyOnComment'],['Commented on my Post - Daily','daily_ReplyOnComment'],['Commented on my Post - Immediate','immediate_ReplyOnComment'],['Commented on my Post - Off','off_ReplyOnComment'],
    ['Also Commented Post - Weekly','weekly_ReplyOnFollowedComment'],['Also Commented Post - Daily','daily_ReplyOnFollowedComment'],['Also Commented Post - Immediate','immediate_ReplyOnFollowedComment'],['Also Commented Post - Off','off_ReplyOnFollowedComment'],


  ]}

  index { render 'index', context: self }

  csv col_sep: ',' do
    column :id
    column :email
    column(:new_meeting) { |u| u.enabled_mail_notification(Notifications::NewMeeting) }
    column(:new_location) { |u| u.enabled_mail_notification(Notifications::NewLocation) }
    column(:new_location_post) { |u| u.enabled_mail_notification(Notifications::NewLocationPost) }
    column(:new_room_offer) { |u| u.enabled_mail_notification(Notifications::NewRoomOffer) }
    column(:new_room_demand) { |u| u.enabled_mail_notification(Notifications::NewRoomDemand) }
    column(:new_room_call) { |u| u.enabled_mail_notification(Notifications::NewRoomCall) }
    column(:commented_content) { |u| u.enabled_mail_notification(Notifications::CommentOnOwnedContent) }
    column(:follow_commented_content) { |u| u.enabled_mail_notification(Notifications::CommentOnFollowedContent) }
    column(:commented_wall) { |u| u.enabled_mail_notification(Notifications::NewWallComment) }
    column(:meeting_attendee) { |u| u.enabled_mail_notification(Notifications::MeetingAttended) }
    column(:meeting_updated) { |u| u.enabled_mail_notification(Notifications::MeetingUpdated) }
    column(:new_group_discussion) { |u| u.enabled_mail_notification(Notifications::NewGroupDiscussion) }
    column(:new_group_meeting) { |u| u.enabled_mail_notification(Notifications::NewGroupMeeting) }
    column(:new_group_post) { |u| u.enabled_mail_notification(Notifications::NewGroupPost) }
    column(:new_crowd_campaign) { |u| u.enabled_mail_notification(Notifications::NewCrowdCampaign) }
  end

end

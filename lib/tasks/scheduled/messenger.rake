namespace :scheduled do

  desc 'Create Messenger Post'
  task create_messenger_post: :environment do

    #ARGV.each { |a| task a.to_sym do ; end }

    # Rake::Task['scheduled:create_messenger_post 1 4'].invoke
    # ARGV[1].to_i = Start User ID
    # ARGV[2].to_i = End User ID

    user_id_start = 1
    user_id_end = 10

    sender = User.find(1)
    chat_message = "Und gleich noch eine an ALLE! :)"

    User.where(id: user_id_start..user_id_end).each do |user|
      next if user.id == sender.id
      thread = UserMessageThread.create_general(sender, user)
      user_message = thread.user_messages.create(user: sender, message: chat_message)

      thread.user_message_thread_members.where(
        user_id: sender.id
      ).where(
        "last_message_seen_id < ?", user_message.id
      ).update_all(
        last_message_seen_id: user_message.id
      )

    end

  end

end

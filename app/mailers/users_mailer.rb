class UsersMailer
  include MailUtils

  def send_welcome_email(user)
    MandrillMailer.deliver(template: 'welcome-new-user', message: email_settings(user))
  end

  private

  def email_settings(user)
    {
      to: [ { email: user.email } ],
      global_merge_vars: [
        { name: 'username', content: user.username },
        { name: 'graetzl_name', content: user.graetzl.name },
        { name: 'graetzl_url', content: graetzl_url(user.graetzl, URL_OPTIONS) }
      ]
    }
  end
end

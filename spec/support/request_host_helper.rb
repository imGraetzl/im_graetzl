module RequestHostHelper
  def set_default_request_host
    host! Rails.application.config.imgraetzl_host
  end

  def reset_request_host!
    host! nil
  end
end

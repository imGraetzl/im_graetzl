# frozen_string_literal: true

Rails.application.config.after_initialize do
  logger = Rails.logger

  level_name =
    case logger.level
    when 0 then "DEBUG"
    when 1 then "INFO"
    when 2 then "WARN"
    when 3 then "ERROR"
    when 4 then "FATAL"
    when 5 then "UNKNOWN"
    else logger.level.to_s
    end

  logger.warn ">>> [LogLevelCheck] Rails.logger.level = #{logger.level} (#{level_name})"
end

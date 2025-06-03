PumaWorkerKiller.config do |config|
  config.ram = (ENV['DYNO_RAM_MB'] || 1024).to_i
  config.frequency = 60 # seconds
  config.percent_usage = (ENV['MAX_MEMORY_USAGE'] || 0.94).to_f
  config.rolling_restart_frequency = false
  Rails.logger.info "Puma worker killer configured with #{config.ram} MB of RAM (#{config.percent_usage * 100}%)"
end

PumaWorkerKiller.start

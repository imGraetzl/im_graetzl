workers (ENV['WEB_CONCURRENCY'] || 1).to_i
threads_count = (ENV['MAX_THREADS'] || 4).to_i
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

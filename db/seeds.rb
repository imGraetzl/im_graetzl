# frozen_string_literal: true

require_relative "seeds/bookables"

def invoke_task_if_exists(task_name)
  return unless Rake::Task.task_defined?(task_name)

  Rake::Task[task_name].invoke
end

invoke_task_if_exists("db:import_districts")
invoke_task_if_exists("db:import_graetzls")

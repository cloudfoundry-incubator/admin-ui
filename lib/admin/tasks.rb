require 'open3'
require_relative 'utils'

module AdminUI
  class Tasks
    def initialize(config, logger)
      @config = config
      @logger = logger

      @tasks_semaphore = Mutex.new
      @tasks           = {}
      @task_index      = 0
    end

    def new_dea
      script_path = File.join(File.dirname(__FILE__), 'scripts', 'newDEA.sh')

      launch_command("#{ script_path }")
    end

    def tasks
      result = []
      tasks = {}

      @tasks_semaphore.synchronize do
        tasks = @tasks.clone
      end

      tasks.each do |task_id, task|
        result.push(:command => task[:command],
                    :id      => task[:id],
                    :started => task[:started],
                    :state   => task[:state])
      end

      result
    end

    def task(task_id, updates, last_task_update)
      task = nil

      @tasks_semaphore.synchronize do
        task = @tasks[task_id]
      end

      return nil if task.nil?

      task[:semaphore].synchronize do
        data = []

        if (updates == 'false') || (last_task_update == 0)
          data = task[:output]
        else
          task[:condition].wait(task[:semaphore]) if last_task_update >= task[:updated]

          task[:output].each do |output|
            data.push(output) if last_task_update < output[:time]
          end
        end

        {
          :id      =>  task[:id],
          :output  =>  data,
          :state   =>  task[:state],
          :updated => task[:updated]
        }
      end
    end

    private

    def launch_command(command)
      task = create_task(command)

      handle_task_output!(task, 'out', :out)
      handle_task_output!(task, 'err', :err)
      wait_task_finished!(task)

      register_task!(task)

      task[:id]
    end

    def create_task(command)
      current_time = Utils.time_in_milliseconds

      task = {
               :command   => command,
               :condition => ConditionVariable.new,
               :output    => [],
               :semaphore => Mutex.new,
               :started   => current_time,
               :state     => 'RUNNING',
               :updated   => current_time
             }

      task[:in], task[:out], task[:err], task[:external] = Open3.popen3(command)

      task
    end

    def handle_task_output!(task, type, type_symbol)
      Thread.new do
        begin
          line = ''
          until line.nil?
            line = task[type_symbol].gets
            update_task!(task, type, line)
          end
        rescue => error
          @logger.debug("Error during handle_task_output!: #{ error.inspect }")
          @logger.debug(error.backtrace.join("\n"))
        end
      end
    end

    def update_task!(task, type, line)
      task[:semaphore].synchronize do
        current_time = Utils.time_in_milliseconds
        task[:updated] = current_time
        task[:output].push(:text => line,
                           :time => current_time,
                           :type => type)
        task[:condition].signal
      end
    end

    def wait_task_finished!(task)
      Thread.new do
        task[:external].join
        task[:semaphore].synchronize do
          task[:state] = 'FINISHED'
          task[:condition].signal
        end
      end
    end

    def register_task!(task)
      @tasks_semaphore.synchronize do
        task[:id] = @task_index

        @tasks[task[:id]] = task

        @task_index += 1
      end
    end
  end
end

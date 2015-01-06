require 'thread'

module ThreadHelper
  def kill_threads
    Thread.list.each do |thread|
      next if thread == Thread.main
      thread.kill
      thread.join
    end
  end
end

# frozen_string_literal: true

module SidekiqFakeScheduler
  class JobWrapper
    def initialize(job)
      @job = job
    end

    def try_perform
      return false if @job.key?('at') && @job['at'] > Time.now.to_f

      perform
      true
    end

    def perform
      delete_from_queues
      worker_class.new.perform(*@job['args'])
    end

    private

    def worker_class
      Object.const_get @job['class']
    end

    def delete_from_queues
      Sidekiq::Queues[@job['queue']].delete @job
      worker_class.jobs.delete @job
    end
  end
end

# frozen_string_literal: true

require 'sidekiq/testing'

require 'sidekiq_fake_scheduler/version'
require 'sidekiq_fake_scheduler/job_wrapper'

module SidekiqFakeScheduler
  # Executes all jobs that are due.
  # In contrast to sidekiq's inline mode, this method only executes jobs that
  # were scheduled for now (or any time previous to now).
  # It does not execute jobs that are scheduled for later.
  # This behavior is really powerful in combination with +timecop+.
  # If any executed job enqueues a new job the new job will get executed as well.
  # The execution order is randomized using +Kernel#rand+
  def self.work
    loop do
      performed_one = Sidekiq::Worker.jobs.sort_by { rand }.any? do |job|
        JobWrapper.new(job).try_perform
      end

      break unless performed_one
    end
  end
end

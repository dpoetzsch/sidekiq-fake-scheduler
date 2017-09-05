# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidekiqFakeScheduler::JobWrapper do
  let(:job) do
    FakeWorker.perform_async(1)
    FakeWorker.jobs[0]
  end
  let(:future_job) do
    FakeWorker.perform_in(2, 1)
    FakeWorker.jobs[0]
  end
  subject { described_class.new(job) }

  describe('#perform') do
    before { subject.perform }

    it 'performs the job' do
      expect(FakeWorker.performs).to eq([1])
    end

    it 'deletes the job from all sidekiq queues' do
      expect(Sidekiq::Queues['default']).to be_empty
      expect(Sidekiq::Worker.jobs).to be_empty
      expect(FakeWorker.jobs).to be_empty
    end
  end

  describe('#try_perform') do
    context 'with immediately due job' do
      before { allow(subject).to receive(:perform) }
      before { subject.try_perform }

      it 'performs the job' do
        expect(subject).to have_received(:perform)
      end
    end

    context 'with job that was already due earlier' do
      let(:job) { future_job }
      before { allow(subject).to receive(:perform) }
      before { Timecop.freeze(3) { subject.try_perform } }

      it 'performs the job' do
        expect(subject).to have_received(:perform)
      end
    end

    context 'with job that is due in the future' do
      let(:job) { future_job }
      before { allow(subject).to receive(:perform) }
      before { subject.try_perform }

      it 'does not perform the job' do
        expect(subject).not_to have_received(:perform)
      end
    end
  end
end

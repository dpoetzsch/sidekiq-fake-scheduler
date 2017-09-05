# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidekiqFakeScheduler do
  describe '#work' do
    context 'with job that is due immediately' do
      before do
        FakeWorker.perform_async(1)
        SidekiqFakeScheduler.work
      end

      it 'performs the job' do
        expect(FakeWorker.performs).to include(1)
      end

      it 'removes the job from the queue' do
        expect(FakeWorker.jobs).to be_empty
      end
    end

    context 'with job that is due later' do
      before do
        FakeWorker.perform_in(5, 1)
        SidekiqFakeScheduler.work
      end

      it 'does not perform the job' do
        expect(FakeWorker.performs).to be_empty
        expect(FakeWorker.jobs).not_to be_empty
      end

      context 'with timecop time traveling' do
        before do
          Timecop.freeze(5) { SidekiqFakeScheduler.work }
        end

        it 'performs the job' do
          expect(FakeWorker.performs).to include(1)
        end

        it 'removes the job from the queue' do
          expect(FakeWorker.jobs).to be_empty
        end
      end
    end

    context 'with job that enqueues another job' do
      before do
        FakeWorker.perform_async(1, 'FakeWorker.perform_async(2)')
        SidekiqFakeScheduler.work
      end

      it 'performs both jobs and removes them from the queue' do
        expect(FakeWorker.performs).to eq([1, 2])
        expect(FakeWorker.jobs).to be_empty
      end
    end
  end
end

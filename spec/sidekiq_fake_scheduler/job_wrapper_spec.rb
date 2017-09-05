# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidekiqFakeScheduler::JobWrapper do
  it 'has a version number' do
    expect(SidekiqFakeScheduler::VERSION).not_to be nil
  end
end

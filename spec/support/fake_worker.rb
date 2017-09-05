# frozen_string_literal: true

class FakeWorker
  include Sidekiq::Worker

  @performs = []
  class << self; attr_reader :performs end

  def perform(id, todo = nil, *_args)
    FakeWorker.performs << id
    # rubocop:disable Security/Eval
    eval(todo) if todo
  end
end

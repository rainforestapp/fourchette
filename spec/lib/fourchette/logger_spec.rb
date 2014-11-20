require 'spec_helper'

describe Fourchette::Logger do
  class FakeClassToTest
    include Fourchette::Logger
  end

  subject { FakeClassToTest.new }

  it { expect(subject.logger.level).to be Logger::INFO }

  context 'first time called' do
    it { expect(subject.logger).to be_a(Logger) }
  end

  context 'each time after' do
    it 'returns the cached version' do
      logger = subject.logger
      expect(subject.logger).to be(logger)
    end
  end
end

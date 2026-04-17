# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NullReleases do
  subject(:instance) { described_class.new }

  describe '#crawlable?' do
    subject { instance.crawlable? }

    it { is_expected.to be false }
  end

  describe '#released_to_searchworks?' do
    subject { instance.released_to_searchworks? }

    it { is_expected.to be false }
  end

  describe '#released_to_earthworks?' do
    subject { instance.released_to_earthworks? }

    it { is_expected.to be false }
  end
end

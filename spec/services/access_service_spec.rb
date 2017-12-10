require 'rails_helper'

RSpec.describe AccessService do
  describe 'authorized?' do
    subject { instance.authorized? }
    let(:instance) { AccessService.new(level: level, agent: agent, identifier: identifier) }

    it 'enforces location based access'

    context 'when requesting read' do
      let(:level) { 'read' }

      context 'as an unidentified user' do
        let(:agent) { Agent.new }

        context 'on a public object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bb157hs6068', file_name: 'bb157hs6068_05_0001') }
          it { is_expected.to be true }
        end

        context 'on a no-download object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'tx027jv4938', file_name: '2012-015GHEW-BW-1984-b4_1.4_0003') }
          it { is_expected.to be false }
        end

        context 'on a stanford-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'zk091xr3370', file_name: 'Wei Huang_PhD Dissertation_Bioengineering_Jan 2012-augmented') }
          it { is_expected.to be false }
        end

        context 'on a citation-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bc421tk1152', file_name: 'bc421tk1152_00_0001') }
          it { is_expected.to be false }
        end
      end

      context 'as a stanford user' do
        let(:agent) { Agent.new(stanford: true) }

        context 'on a stanford-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'zk091xr3370', file_name: 'Wei Huang_PhD Dissertation_Bioengineering_Jan 2012-augmented') }
          it { is_expected.to be true }
        end

        context 'on a no-download object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'tx027jv4938', file_name: '2012-015GHEW-BW-1984-b4_1.4_0003') }
          it { is_expected.to be true }
        end

        context 'on a citation-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bc421tk1152', file_name: 'bc421tk1152_00_0001') }
          it { is_expected.to be false }
        end
      end
    end

    context 'when requesting download' do
      let(:level) { 'download' }

      context 'as an unidentified user' do
        let(:agent) { Agent.new }

        context 'on a public object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bb157hs6068', file_name: 'bb157hs6068_05_0001') }
          it { is_expected.to be true }
        end

        context 'on a no-download object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'tx027jv4938', file_name: '2012-015GHEW-BW-1984-b4_1.4_0003') }
          it { is_expected.to be false }
        end

        context 'on a stanford-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'zk091xr3370', file_name: 'Wei Huang_PhD Dissertation_Bioengineering_Jan 2012-augmented') }
          it { is_expected.to be false }
        end

        context 'on a citation-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bc421tk1152', file_name: 'bc421tk1152_00_0001') }
          it { is_expected.to be false }
        end
      end

      context 'as a stanford user' do
        let(:agent) { Agent.new(stanford: true) }

        context 'on a stanford-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'zk091xr3370', file_name: 'Wei Huang_PhD Dissertation_Bioengineering_Jan 2012-augmented') }
          it { is_expected.to be true }
        end

        context 'on a no-download object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'tx027jv4938', file_name: '2012-015GHEW-BW-1984-b4_1.4_0003') }
          it { is_expected.to be true }
        end

        context 'on a citation-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bc421tk1152', file_name: 'bc421tk1152_00_0001') }
          it { is_expected.to be false }
        end
      end
    end

    context 'when requesting access' do
      let(:level) { 'access' }

      context 'as an unidentified user' do
        let(:agent) { Agent.new }

        context 'on a public object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bb157hs6068', file_name: 'bb157hs6068_05_0001') }
          it { is_expected.to be true }
        end

        context 'on a no-download object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'tx027jv4938', file_name: '2012-015GHEW-BW-1984-b4_1.4_0003') }
          it { is_expected.to be true }
        end

        context 'on a stanford-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'zk091xr3370', file_name: 'Wei Huang_PhD Dissertation_Bioengineering_Jan 2012-augmented') }
          it { is_expected.to be false }
        end

        context 'on a citation-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bc421tk1152', file_name: 'bc421tk1152_00_0001') }
          it { is_expected.to be false }
        end
      end

      context 'as a stanford user' do
        let(:agent) { Agent.new(stanford: true) }

        context 'on a stanford-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'zk091xr3370', file_name: 'Wei Huang_PhD Dissertation_Bioengineering_Jan 2012-augmented') }
          it { is_expected.to be true }
        end

        context 'on a no-download object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'tx027jv4938', file_name: '2012-015GHEW-BW-1984-b4_1.4_0003') }
          it { is_expected.to be true }
        end

        context 'on a citation-only object' do
          let(:identifier) { ResourceIdentifier.new(druid: 'bc421tk1152', file_name: 'bc421tk1152_00_0001') }
          it { is_expected.to be false }
        end
      end
    end
  end
end

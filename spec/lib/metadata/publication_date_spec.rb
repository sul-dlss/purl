require 'rails_helper'

RSpec.describe Metadata::PublicationDate do
  let(:publication_date) { described_class.call(Nokogiri::XML(mods).root) }

  context 'when publication date' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo eventType="publication">
            <place>
              <placeTerm type="text">Philadelphia</placeTerm>
            </place>
            <publisher>Mathew Carey</publisher>
            <dateIssued encoding="w3cdtf" keyDate="yes">1795</dateIssued>
          </originInfo>
        </mods>
      XML
    end

    it 'returns the publication date' do
      expect(publication_date).to eq('1795')
    end
  end

  context 'when no publication date' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo eventType="deposit">
            <dateIssued encoding="edtf">2022-09-22</dateIssued>
          </originInfo>
        </mods>
      XML
    end

    it 'returns other date' do
      expect(publication_date).to eq('2022')
    end
  end

  context 'when no date' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
        </mods>
      XML
    end

    it 'returns nil' do
      expect(publication_date).to be_nil
    end
  end
end

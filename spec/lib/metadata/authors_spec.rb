require 'rails_helper'

RSpec.describe Metadata::Authors do
  let(:authors) { described_class.call(Nokogiri::XML(mods)) }

  context 'when no names' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
        </mods>
      XML
    end

    it 'returns empty array' do
      expect(authors).to be_empty
    end
  end

  context 'when names with author roles' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
        <name usage="primary" type="personal">
          <namePart type="given">Vicky Chuqiao</namePart>
          <namePart type="family">Yang</namePart>
          <role>
            <roleTerm valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/" type="text">author</roleTerm>
            <roleTerm valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/" type="code">aut</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Sandberg, Anders</namePart>
          <role>
            <roleTerm valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/" type="code">AUT</roleTerm>
          </role>
        </name>
        </mods>
      XML
    end

    it 'returns names' do
      expect(authors).to eq ['Yang, Vicky Chuqiao', 'Sandberg, Anders']
    end
  end

  context 'when only names with no roles' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <name usage="primary" type="personal">
            <namePart type="given">Vicky Chuqiao</namePart>
            <namePart type="family">Yang</namePart>
          </name>
          <name type="personal">
            <namePart type="given">Anders</namePart>
            <namePart type="family">Sandberg</namePart>
          </name>
        </mods>
      XML
    end

    it 'returns names' do
      expect(authors).to eq ['Yang, Vicky Chuqiao', 'Sandberg, Anders']
    end
  end

  context 'when only first name with any role' do
    let(:mods) do
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <name usage="primary" type="personal">
            <namePart type="given">Sandi</namePart>
            <namePart type="family">Khine</namePart>
            <role>
              <roleTerm valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/" type="text">author</roleTerm>
              <roleTerm valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/" type="code">aut</roleTerm>
            </role>
          </name>
        </mods>
      XML
    end

    it 'returns names' do
      expect(authors).to eq ['Khine, Sandi']
    end
  end
end

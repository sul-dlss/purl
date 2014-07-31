require 'spec_helper'

describe PurlHelper, type: :helper do
  class TestClass
  end

  before do
    @purl = PurlObject.new('zk091xr3370')

    helper = TestClass.new
    helper.extend(PurlHelper)
  end

  describe 'util functions' do
    it 'should return number of items per gallery page' do
      expect(helper.get_gallery_items_per_page_count).to eq(15)
    end

    it 'should trim text of multiple spaces and newlines' do
      expect(helper.trim_text("  abc\rdef  ")).to eq(" abc def ")
    end

    it 'should add links to URIs' do
      expect(helper.add_links_to_URIs('lorem http://abc.com ipsum')).to eq('lorem <a href="http://abc.com">http://abc.com</a> ipsum')
    end

    it 'should convert date string to %Y-%m-%d format' do
      expect(helper.format_date_string('2013-07-30T10:26:17-07:00')).to eq('2013-07-30')
    end
  end

  describe 'metadata functions' do
    it 'should print creator value' do
      expect(helper.print_creator_value('Creator')).to eq('<dt>Creator:</dt><dd>Huang, Wei.</dd>')
    end

    it 'should get searchworks link' do
      expect(helper.get_searchworks_link).to eq('<a href="http://searchworks.stanford.edu/view/9447984">View in SearchWorks</a>')
    end

    it 'should check embargo status' do
      expect(helper.embargoExpired).to eq(false)
    end

    it 'should get embargo text if embargo exists' do
      expect(helper.get_embargo_text).to eq('Access: Stanford only until 2020-01-18')
    end

    it 'should get sidebar links' do
      expect(helper.get_sidebar_links).to eq('<p><a href="http://searchworks.stanford.edu/view/9447984">View in SearchWorks</a></p><br/><p><strong>Available download formats:</strong> </p> <ul><li><a href="http://stacks-test.stanford.edu/file/druid:zk091xr3370/bw662rg0319_31_0000.pdf">bw662rg0319_31_0000.pdf</a> (70 MB)&nbsp; <img src="/images/icon-download.png"></li></ul>')
    end

  end

end

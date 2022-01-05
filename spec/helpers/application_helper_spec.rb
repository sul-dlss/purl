require 'rails_helper'

describe ApplicationHelper do
  describe '#format_mods_content' do
    it 'makes the string html safe' do
      expect(helper.format_mods_content(['blah'])).to be_html_safe
    end

    it 'separates duplicate values into paragraphs' do
      expect(helper.format_mods_content(%w[a b])).to eq "<p>a</p>\n\n<p>b</p>"
    end

    it 'separates encoded new lines into paragraphs' do
      expect(helper.format_mods_content(['a&#10;&#10;b'])).to eq "<p>a</p>\n\n<p>b</p>"
    end

    it 'escapes data' do
      value = '1. sér. (1787 à 1799) t. 1-<t. 82>; --2. sér. (1880-1860) t. 1-127, 1862-1913.'
      expected = '1. sér. (1787 à 1799) t. 1-&lt;t. 82&gt;; --2. sér. (1880-1860) t. 1-127, 1862-1913.'
      expect(helper.format_mods_content([value])).to eq "<p>#{expected}</p>"
    end
  end
end

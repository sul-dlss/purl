# frozen_string_literal: true

class ContributorComponent < ViewComponent::Base
  def initialize(contributor:)
    @contributor = contributor
    super()
  end

  attr_reader :contributor

  def orcid
    @orcid ||= contributor.identifiers.find { it.type == 'ORCID' }
  end

  def name
    contributor.display_name(with_date: true)
  end

  def orcid_icon
    tag.span class: 'orcid' do
      link_to(orcid.uri, class: 'su-underline orcid-link', aria: { label: "view ORCID page for #{contributor.display_name(with_date: true)}" }) do
        image_tag('https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png', alt: 'ORCiD icon', class: 'orcid-icon') +
          orcid.uri
      end
    end
  end
end

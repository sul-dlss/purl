# frozen_string_literal: true

class ContributorsComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :contributor_display_data, to: :cocina_display

  def render?
    contributor_display_data.present?
  end

  def label_id
    'section-creators'
  end

  def orcid_icon(contributor, name)
    return unless contributor.orcid?

    tag.span class: 'orcid' do
      link_to(contributor.orcid, class: 'su-underline orcid-link text-nowrap', aria: { label: "view ORCID page for #{name}" }) do
        image_tag('https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png', alt: 'ORCiD icon', class: 'orcid-icon') +
          contributor.orcid
      end
    end
  end
end

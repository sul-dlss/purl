# frozen_string_literal: true

class ContributorsComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def render?
    contributors_by_role.present?
  end

  def contributors_by_role
    @contributors_by_role ||= cocina_display.contributors_by_role
                                            .excluding('publisher')
                                            .transform_keys { it.nil? ? 'Associated with' : it.titleize }
  end

  def label_id
    'section-creators'
  end

  def orcid_icon(contributor, name)
    orcid = contributor.identifiers.find { it.type == 'ORCID' }

    return unless orcid

    tag.span class: 'orcid' do
      link_to(orcid.uri, class: 'su-underline orcid-link', aria: { label: "view ORCID page for #{name}" }) do
        image_tag('https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png', alt: 'ORCiD icon', class: 'orcid-icon') +
          orcid.uri
      end
    end
  end
end

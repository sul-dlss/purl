# frozen_string_literal: true

module Show
  class HeadMetadataComponent < ViewComponent::Base
    def initialize(version:, purl:)
      @version = version
      @purl = purl
      super()
    end

    attr_accessor :version, :purl

    delegate :embeddable?, :containing_collections, :cocina_body, :druid, :version_id, :cocina_display, :display_title,
             :representative_thumbnail, :representative_thumbnail?, :withdrawn?, to: :version
    delegate :releases, to: :purl
    delegate :abstract_display_data, :subject_all, to: :cocina_display

    def schema_dot_org?
      ::Metadata::SchemaDotOrg.schema_type?(@version.cocina_display)
    end

    def schema_dot_org
      ::Metadata::SchemaDotOrg.call(@version.cocina_display, thumbnail: representative_thumbnail)
    end

    def title
      "#{display_title} | Stanford Digital Repository"
    end

    def oembed_path(format)
      oembed_url_template.expand(format: format, application_options: oembed_url_template_options, url: embeddable_url)
    end

    def oembed_url_template
      @oembed_url_template ||= Addressable::Template.new(Settings.embed.url_template)
    end

    def oembed_url_template_options
      params.permit(*Settings.embed.application_options.to_h.keys).to_h
    end

    def keywords
      subject_all.join(',')
    end

    def description
      abstract_display_data.flat_map(&:values).first
    end

    # Create the URL to pass to the embed service.  The embed service will create the viewer we display on the page.
    def embeddable_url
      args = Rails.env.development? ? { host: 'purl.stanford.edu' } : {}
      versioned_path = version_purl_url(druid, version_id, args)

      current_page?(versioned_path) ? versioned_path : purl_url(druid, args)
    end
  end
end

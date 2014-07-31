require 'cgi'
require 'net/https'
require 'uri'

module Dor

  class Connection

    def Connection.get(full_url)
      Connection.connect(full_url, :get, nil, nil)
    end

    def Connection.post(full_url, body, content_type = 'application/xml')
      Connection.connect(full_url, :post, body, content_type)
    end

    def Connection.put(full_url, body, content_type = 'application/xml')
      Connection.connect(full_url, :put, body, content_type)
    end

    private

    def Connection.get_http_connection(url)
      http = Net::HTTP.new(url.host, url.port)
    end

    def Connection.get_https_connection(url)
      https = get_http_connection(url)
      if(url.scheme == 'https')
        https.use_ssl = true
        https.cert = OpenSSL::X509::Certificate.new( File.read(Settings.fedora.cert) )
        https.key = OpenSSL::PKey::RSA.new( File.read(Settings.fedora.key), Settings.fedora.pass )
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      https
    end

    def Connection.connect(full_url, method, body, content_type)
      url = URI.parse(full_url)
      case method
        when :get
          request = Net::HTTP::Get.new(url.request_uri)
        when :post
          request = Net::HTTP::Post.new(url.request_uri)
        when :put
          request = Net::HTTP::Put.new(url.request_uri)
        end
        request.body = body unless(body.nil?)
        request.content_type = content_type unless(content_type.nil?)
        response = Connection.get_https_connection(url).start {|http| http.request(request) }
        case response
          when Net::HTTPSuccess
            return response.body
          else
            raise response.error!
        end
      end
    end

end

# https://github.com/ankane/ahoy

class Ahoy::Store < Ahoy::DatabaseStore
end

# enable the API for tracking events client-side via sul-embed
Ahoy.api = true

# only create a visit object server-side once events are logged via JS
Ahoy.server_side_visits = :when_needed

# mask IPs by setting the last octet to 0
Ahoy.mask_ips = true

# enable event logging in development
Ahoy.quiet = !Rails.env.development?

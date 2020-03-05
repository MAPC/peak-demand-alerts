# frozen_string_literal: true

require 'open-uri'
require 'net/https'

module Net
  class HTTP
    alias original_use_ssl= use_ssl=

    def use_ssl=(flag)
      self.ca_path = Rails.root.join('lib/ca-bundle.crt').to_s
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end

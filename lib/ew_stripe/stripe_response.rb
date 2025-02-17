# frozen_string_literal: true

module EwStripe
  # Headers provides an access wrapper to an API response's header data. It
  # mainly exists so that we don't need to expose the entire
  # `Net::HTTPResponse` object while still getting some of its benefits like
  # case-insensitive access to header names and flattening of header values.
  class StripeResponseHeaders
    # Initializes a Headers object from a Net::HTTP::HTTPResponse object.
    def self.from_net_http(resp)
      new(resp.to_hash)
    end

    # `hash` is expected to be a hash mapping header names to arrays of
    # header values. This is the default format generated by calling
    # `#to_hash` on a `Net::HTTPResponse` object because headers can be
    # repeated multiple times. Using `#[]` will collapse values down to just
    # the first.
    def initialize(hash)
      if !hash.is_a?(Hash) ||
         !hash.keys.all? { |n| n.is_a?(String) } ||
         !hash.values.all? { |a| a.is_a?(Array) } ||
         !hash.values.all? { |a| a.all? { |v| v.is_a?(String) } }
        raise ArgumentError,
              "expect hash to be a map of string header names to arrays of " \
              "header values"
      end

      @hash = {}

      # This shouldn't be strictly necessary because `Net::HTTPResponse` will
      # produce a hash with all headers downcased, but do it anyway just in
      # case an object of this class was constructed manually.
      #
      # Also has the effect of duplicating the hash, which is desirable for a
      # little extra object safety.
      hash.each do |k, v|
        @hash[k.downcase] = v
      end
    end

    def [](name)
      values = @hash[name.downcase]
      if values && values.count > 1
        warn("Duplicate header values for `#{name}`; returning only first")
      end
      values ? values.first : nil
    end
  end

  module StripeResponseBase
    # A Hash of the HTTP headers of the response.
    attr_accessor :http_headers

    # The integer HTTP status code of the response.
    attr_accessor :http_status

    # The EwStripe request ID of the response.
    attr_accessor :request_id

    def self.populate_for_net_http(resp, http_resp)
      resp.http_headers = StripeResponseHeaders.from_net_http(http_resp)
      resp.http_status = http_resp.code.to_i
      resp.request_id = http_resp["request-id"]
    end
  end

  # StripeResponse encapsulates some vitals of a response that came back from
  # the EwStripe API.
  class StripeResponse
    include StripeResponseBase
    # The data contained by the HTTP body of the response deserialized from
    # JSON.
    attr_accessor :data

    # The raw HTTP body of the response.
    attr_accessor :http_body

    # Initializes a StripeResponse object from a Net::HTTP::HTTPResponse
    # object.
    def self.from_net_http(http_resp)
      resp = StripeResponse.new
      resp.data = JSON.parse(http_resp.body, symbolize_names: true)
      resp.http_body = http_resp.body
      StripeResponseBase.populate_for_net_http(resp, http_resp)
      resp
    end
  end

  # We have to alias StripeResponseHeaders to StripeResponse::Headers, as this
  # class used to be embedded within StripeResponse and we want to be backwards
  # compatible.
  StripeResponse::Headers = StripeResponseHeaders

  # StripeHeadersOnlyResponse includes only header-related vitals of the
  # response. This is used for streaming requests where the response was read
  # directly in a block and we explicitly don't want to store the body of the
  # response in memory.
  class StripeHeadersOnlyResponse
    include StripeResponseBase

    # Initializes a StripeHeadersOnlyResponse object from a
    # Net::HTTP::HTTPResponse object.
    def self.from_net_http(http_resp)
      resp = StripeHeadersOnlyResponse.new
      StripeResponseBase.populate_for_net_http(resp, http_resp)
      resp
    end
  end
end

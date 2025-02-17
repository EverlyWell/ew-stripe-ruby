# File generated from our OpenAPI spec
# frozen_string_literal: true

module EwStripe
  class EphemeralKey < APIResource
    extend EwStripe::APIOperations::Create
    include EwStripe::APIOperations::Delete

    OBJECT_NAME = "ephemeral_key"

    def self.create(params = {}, opts = {})
      opts = Util.normalize_opts(opts)
      unless opts[:stripe_version]
        raise ArgumentError,
              "stripe_version must be specified to create an ephemeral key"
      end
      super
    end
  end
end

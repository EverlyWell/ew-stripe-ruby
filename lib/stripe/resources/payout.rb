# File generated from our OpenAPI spec
# frozen_string_literal: true

module EwStripe
  class Payout < APIResource
    extend EwStripe::APIOperations::Create
    extend EwStripe::APIOperations::List
    include EwStripe::APIOperations::Save

    OBJECT_NAME = "payout"

    custom_method :cancel, http_verb: :post
    custom_method :reverse, http_verb: :post

    def cancel(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/cancel",
        params: params,
        opts: opts
      )
    end

    def reverse(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/reverse",
        params: params,
        opts: opts
      )
    end
  end
end

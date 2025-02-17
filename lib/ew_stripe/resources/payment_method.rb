# File generated from our OpenAPI spec
# frozen_string_literal: true

module EwStripe
  class PaymentMethod < APIResource
    extend EwStripe::APIOperations::Create
    extend EwStripe::APIOperations::List
    include EwStripe::APIOperations::Save

    OBJECT_NAME = "payment_method"

    custom_method :attach, http_verb: :post
    custom_method :detach, http_verb: :post

    def attach(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/attach",
        params: params,
        opts: opts
      )
    end

    def detach(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/detach",
        params: params,
        opts: opts
      )
    end
  end
end

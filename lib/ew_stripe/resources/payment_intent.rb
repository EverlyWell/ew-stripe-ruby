# File generated from our OpenAPI spec
# frozen_string_literal: true

module EwStripe
  class PaymentIntent < APIResource
    extend EwStripe::APIOperations::Create
    extend EwStripe::APIOperations::List
    include EwStripe::APIOperations::Save

    OBJECT_NAME = "payment_intent"

    custom_method :cancel, http_verb: :post
    custom_method :capture, http_verb: :post
    custom_method :confirm, http_verb: :post

    def cancel(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/cancel",
        params: params,
        opts: opts
      )
    end

    def capture(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/capture",
        params: params,
        opts: opts
      )
    end

    def confirm(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/confirm",
        params: params,
        opts: opts
      )
    end
  end
end

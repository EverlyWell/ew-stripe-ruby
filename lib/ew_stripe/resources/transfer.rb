# File generated from our OpenAPI spec
# frozen_string_literal: true

module EwStripe
  class Transfer < APIResource
    extend EwStripe::APIOperations::Create
    extend EwStripe::APIOperations::List
    include EwStripe::APIOperations::Save
    extend EwStripe::APIOperations::NestedResource

    OBJECT_NAME = "transfer"

    custom_method :cancel, http_verb: :post

    nested_resource_class_methods :reversal,
                                  operations: %i[create retrieve update list]

    def cancel(params = {}, opts = {})
      request_stripe_object(
        method: :post,
        path: resource_url + "/cancel",
        params: params,
        opts: opts
      )
    end
  end
end

# frozen_string_literal: true

require ::File.expand_path("../test_helper", __dir__)

module EwStripe
  class ApplicationFeeTest < Test::Unit::TestCase
    should "be listable" do
      fees = EwStripe::ApplicationFee.list
      assert_requested :get, "#{EwStripe.api_base}/v1/application_fees"
      assert fees.data.is_a?(Array)
      assert fees.data[0].is_a?(EwStripe::ApplicationFee)
    end

    context "#create_refund" do
      should "create a refund" do
        refund = EwStripe::ApplicationFee.create_refund(
          "fee_123"
        )
        assert_requested :post, "#{EwStripe.api_base}/v1/application_fees/fee_123/refunds"
        assert refund.is_a?(EwStripe::ApplicationFeeRefund)
      end
    end

    context "#retrieve_refund" do
      should "retrieve a refund" do
        refund = EwStripe::ApplicationFee.retrieve_refund(
          "fee_123",
          "fr_123"
        )
        assert_requested :get, "#{EwStripe.api_base}/v1/application_fees/fee_123/refunds/fr_123"
        assert refund.is_a?(EwStripe::ApplicationFeeRefund)
      end
    end

    context "#update_refund" do
      should "update a refund" do
        refund = EwStripe::ApplicationFee.update_refund(
          "fee_123",
          "fr_123",
          metadata: { foo: "bar" }
        )
        assert_requested :post, "#{EwStripe.api_base}/v1/application_fees/fee_123/refunds/fr_123"
        assert refund.is_a?(EwStripe::ApplicationFeeRefund)
      end
    end

    context "#list_refunds" do
      should "list the application fee's refuns" do
        refunds = EwStripe::ApplicationFee.list_refunds(
          "fee_123"
        )
        assert_requested :get, "#{EwStripe.api_base}/v1/application_fees/fee_123/refunds"
        assert refunds.is_a?(EwStripe::ListObject)
        assert refunds.data.is_a?(Array)
      end
    end
  end
end

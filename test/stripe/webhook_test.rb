# frozen_string_literal: true

require ::File.expand_path("../test_helper", __dir__)

module EwStripe
  class WebhookTest < Test::Unit::TestCase
    EVENT_PAYLOAD = <<~PAYLOAD
      {
        "id": "evt_test_webhook",
        "object": "event"
      }
    PAYLOAD
    SECRET = "whsec_test_secret"

    def generate_header(opts = {})
      opts[:timestamp] ||= Time.now
      opts[:payload] ||= EVENT_PAYLOAD
      opts[:secret] ||= SECRET
      opts[:scheme] ||= EwStripe::Webhook::Signature::EXPECTED_SCHEME
      opts[:signature] ||= EwStripe::Webhook::Signature.compute_signature(
        opts[:timestamp],
        opts[:payload],
        opts[:secret]
      )
      EwStripe::Webhook::Signature.generate_header(
        opts[:timestamp],
        opts[:signature],
        scheme: opts[:scheme]
      )
    end

    context ".compute_signature" do
      should "compute a signature which can then be verified" do
        timestamp = Time.now
        signature = EwStripe::Webhook::Signature.compute_signature(
          timestamp,
          EVENT_PAYLOAD,
          SECRET
        )
        header = generate_header(timestamp: timestamp, signature: signature)
        assert(EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, SECRET))
      end
    end

    context ".generate_header" do
      should "generate a header in valid format" do
        timestamp = Time.now
        signature = EwStripe::Webhook::Signature.compute_signature(
          timestamp,
          EVENT_PAYLOAD,
          SECRET
        )
        scheme = "v1"
        header = EwStripe::Webhook::Signature.generate_header(
          timestamp,
          signature,
          scheme: scheme
        )
        assert_equal("t=#{timestamp.to_i},#{scheme}=#{signature}", header)
      end
    end

    context ".construct_event" do
      should "return an Event instance from a valid JSON payload and valid signature header" do
        header = generate_header
        event = EwStripe::Webhook.construct_event(EVENT_PAYLOAD, header, SECRET)
        assert event.is_a?(EwStripe::Event)
      end

      should "raise a JSON::ParserError from an invalid JSON payload" do
        assert_raises JSON::ParserError do
          payload = "this is not valid JSON"
          header = generate_header(payload: payload)
          EwStripe::Webhook.construct_event(payload, header, SECRET)
        end
      end

      should "raise a SignatureVerificationError from a valid JSON payload and an invalid signature header" do
        header = "bad_header"
        assert_raises EwStripe::SignatureVerificationError do
          EwStripe::Webhook.construct_event(EVENT_PAYLOAD, header, SECRET)
        end
      end
    end

    context ".verify_signature_header" do
      should "raise a SignatureVerificationError when the header does not have the expected format" do
        header = "i'm not even a real signature header"
        e = assert_raises(EwStripe::SignatureVerificationError) do
          EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, "secret")
        end
        assert_match("Unable to extract timestamp and signatures from header", e.message)
      end

      should "raise a SignatureVerificationError when there are no signatures with the expected scheme" do
        header = generate_header(scheme: "v0")
        e = assert_raises(EwStripe::SignatureVerificationError) do
          EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, "secret")
        end
        assert_match("No signatures found with expected scheme", e.message)
      end

      should "raise a SignatureVerificationError when there are no valid signatures for the payload" do
        header = generate_header(signature: "bad_signature")
        e = assert_raises(EwStripe::SignatureVerificationError) do
          EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, "secret")
        end
        assert_match("No signatures found matching the expected signature for payload", e.message)
      end

      should "raise a SignatureVerificationError when the timestamp is not within the tolerance" do
        header = generate_header(timestamp: Time.now - 15)
        e = assert_raises(EwStripe::SignatureVerificationError) do
          EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, SECRET, tolerance: 10)
        end
        assert_match("Timestamp outside the tolerance zone", e.message)
      end

      should "return true when the header contains a valid signature and the timestamp is within the tolerance" do
        header = generate_header
        assert(EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, SECRET, tolerance: 10))
      end

      should "return true when the header contains at least one valid signature" do
        header = generate_header + ",v1=bad_signature"
        assert(EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, SECRET, tolerance: 10))
      end

      should "return true when the header contains a valid signature and the timestamp is off but no tolerance is provided" do
        header = generate_header(timestamp: Time.at(12_345))
        assert(EwStripe::Webhook::Signature.verify_header(EVENT_PAYLOAD, header, SECRET))
      end
    end
  end
end

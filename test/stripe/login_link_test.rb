# frozen_string_literal: true

require ::File.expand_path("../test_helper", __dir__)

module EwStripe
  class LoginLinkTest < Test::Unit::TestCase
    setup do
      account_fixture = {
        "id" => "acct_123",
        "object" => "account",
        "login_links" => {
          "data" => [],
          "has_more" => false,
          "object" => "list",
          "url" => "/v1/accounts/acct_123/login_links",
        },
      }
      @account = EwStripe::Account.construct_from(account_fixture)
    end

    should "not be retrievable" do
      assert_raises NotImplementedError do
        EwStripe::LoginLink.retrieve("foo")
      end
    end

    should "be creatable" do
      stub_request(:post, "#{EwStripe.api_base}/v1/accounts/#{@account.id}/login_links")
        .to_return(body: JSON.generate(object: "login_link"))

      login_link = @account.login_links.create
      assert_requested :post,
                       "#{EwStripe.api_base}/v1/accounts/#{@account.id}/login_links"
      assert login_link.is_a?(EwStripe::LoginLink)
    end
  end
end

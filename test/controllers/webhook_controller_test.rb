require 'test_helper'

class WebhookControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end

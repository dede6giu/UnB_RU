require "test_helper"

class TurnstilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @turnstile = turnstiles(:one)
  end

  test "should get index" do
    get turnstiles_url
    assert_response :success
  end

  test "should get new" do
    get new_turnstile_url
    assert_response :success
  end

  test "should create turnstile" do
    assert_difference("Turnstile.count") do
      post turnstiles_url, params: { turnstile: { name: @turnstile.name, operation: @turnstile.operation } }
    end

    assert_redirected_to turnstile_url(Turnstile.last)
  end

  test "should show turnstile" do
    get turnstile_url(@turnstile)
    assert_response :success
  end

  test "should get edit" do
    get edit_turnstile_url(@turnstile)
    assert_response :success
  end

  test "should update turnstile" do
    patch turnstile_url(@turnstile), params: { turnstile: { name: @turnstile.name, operation: @turnstile.operation } }
    assert_redirected_to turnstile_url(@turnstile)
  end

  test "should destroy turnstile" do
    assert_difference("Turnstile.count", -1) do
      delete turnstile_url(@turnstile)
    end

    assert_redirected_to turnstiles_url
  end
end

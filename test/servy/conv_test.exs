defmodule Servy.ConvTest do
  use ExUnit.Case

  alias Servy.Conv

  test "full_status" do
    assert Conv.full_status(%Conv{status: 200}) == "200 OK"
    assert Conv.full_status(%Conv{status: 201}) == "201 Created"
    assert Conv.full_status(%Conv{status: 400}) == "400 Bad Request"
    assert Conv.full_status(%Conv{status: 401}) == "401 Unauthorized"
    assert Conv.full_status(%Conv{status: 403}) == "403 Forbidden"
    assert Conv.full_status(%Conv{status: 404}) == "404 Not Found"
    assert Conv.full_status(%Conv{status: 500}) == "500 Internal Server Error"
  end
end

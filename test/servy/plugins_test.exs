defmodule Servy.PluginsTest do
  use ExUnit.Case

  alias Servy.Plugins
  alias Servy.Conv

  test "rewrite_path" do
    conv = %Conv{
      path: "/wildlife"
    }

    new_conv = %Conv{
      path: "/wildthings"
    }

    assert new_conv == Plugins.rewrite_path(conv)
  end

  test "rewrite_path with id" do
    conv = %Conv{
      path: "/bears?id=123"
    }

    new_conv = %Conv{
      path: "/bears/123"
    }

    assert new_conv == Plugins.rewrite_path(conv)
  end

  test "track 404" do
    io =
      ExUnit.CaptureLog.capture_log(fn ->
        Plugins.track(%Conv{
          method: "GET",
          path: "/bigfoot",
          status: 404
        })
      end)

    assert io =~ "GET /bigfoot 404\n"
  end

  test "emojify" do
    conv = %Conv{method: "GET", status: 200, resp_body: "this should get emojified!"}
    new_conv = %{conv | resp_body: "👍 this should get emojified! 🔥"}
    assert new_conv == Plugins.emojify(conv)

    conv = %Conv{method: "GET", status: 404, resp_body: "this should NOT get emojified"}
    assert conv == Plugins.emojify(conv)
  end

  test "content_length for empty response body" do
    conv = %Conv{resp_body: ""}
    assert %{"Content-Length" => 0} = Plugins.content_length(conv).resp_headers
  end

  test "content_length for non-empty response body" do
    conv = %Conv{resp_body: "hi"}
    assert %{"Content-Length" => 2} = Plugins.content_length(conv).resp_headers
  end
end

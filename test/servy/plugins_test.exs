defmodule Servy.PluginsTest do
  use ExUnit.Case

  alias Servy.Plugins
  alias Servy.Handler

  test "rewrite_path" do
    conv = %Handler{
      path: "/wildlife"
    }

    new_conv = %Handler{
      path: "/wildthings"
    }

    assert new_conv == Plugins.rewrite_path(conv)
  end

  test "rewrite_path with id" do
    conv = %Handler{
      path: "/bears?id=123"
    }

    new_conv = %Handler{
      path: "/bears/123"
    }

    assert new_conv == Plugins.rewrite_path(conv)
  end

  test "track 404" do
    io =
      ExUnit.CaptureLog.capture_log(fn ->
        Plugins.track(%Handler{
          method: "GET",
          path: "/bigfoot",
          status: 404
        })
      end)

    assert io =~ "GET /bigfoot 404\n"
  end

  test "emojify" do
    conv = %Handler{method: "GET", status: 200, resp_body: "this should get emojified!"}
    new_conv = %{conv | resp_body: "👍 this should get emojified! 🔥"}
    assert new_conv == Plugins.emojify(conv)

    conv = %Handler{method: "GET", status: 404, resp_body: "this should NOT get emojified"}
    assert conv == Plugins.emojify(conv)
  end
end

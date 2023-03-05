defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            headers: %{},
            params: %{},
            resp_body: "",
            status: nil

  alias Servy.Conv

  def full_status(%Conv{status: status}) do
    "#{status} #{status_reason(status)}"
  end

  defp status_reason(200), do: "OK"
  defp status_reason(201), do: "Created"
  defp status_reason(400), do: "Bad Request"
  defp status_reason(401), do: "Unauthorized"
  defp status_reason(403), do: "Forbidden"
  defp status_reason(404), do: "Not Found"
  defp status_reason(500), do: "Internal Server Error"
end

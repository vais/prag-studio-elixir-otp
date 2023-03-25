defmodule Servy.PledgeController do
  alias Servy.{Conv, PledgeServer}

  def index(%Conv{} = conv) do
    pledges = PledgeServer.recent_pledges()
    %{conv | status: 200, resp_body: inspect(pledges)}
  end

  def create(%Conv{} = conv, params) do
    %{"name" => name, "amount" => amount} = params
    PledgeServer.create_pledge(name, String.to_integer(amount))
    %{conv | status: 201, resp_body: "#{name} pledged #{amount}"}
  end
end

defmodule Servy.VideoCam do
  def get_snapshot(cam_name) do
    Process.sleep(1000)
    "#{cam_name}-snapshot.jpg"
  end
end

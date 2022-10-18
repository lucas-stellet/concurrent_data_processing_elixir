defmodule Sender do
  @moduledoc false

  def send_email("hello@world.com" = _email), do: :error

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    :ok
  end

  def notify_all(emails) do
    emails
    |> Enum.map(&Task.async(fn -> send_email(&1) end))
    |> Enum.map(&Task.await/1)
  end

  def notify_all_stream(emails) do
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream_nolink(emails, &send_email/1, ordered: false)
    |> Enum.to_list()
  end
end

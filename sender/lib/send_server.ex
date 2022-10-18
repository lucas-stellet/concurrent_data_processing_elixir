defmodule SendServer do
  use GenServer

  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")

    max_retries = Keyword.get(args, :max_retries, 5)

    retry_failed_emails()

    {:ok, %{emails: [], max_retries: max_retries}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send, email}, state = %{emails: emails}) do
    status = send_email(email)

    emails = [%{email: email, status: status, retries: 0}] ++ emails

    {:noreply, %{state | emails: emails}}
  end

  def handle_info(:retry, state) do
    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == "failed" && item.retries < state.max_retries
      end)

    retried =
      Enum.map(failed, fn item ->
        IO.puts("Retrying email #{item.email}...")

        new_status = send_email(item.email)

        retry_failed_emails()

        %{email: item.email, status: new_status, retries: item.retries + 1}
      end)

    {:noreply, %{state | emails: retried ++ done}}
  end

  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end

  defp send_email(email) do
    case Sender.send_email(email) do
      :ok -> "sent"
      :error -> "failed"
    end
  end

  defp retry_failed_emails, do: Process.send_after(self(), :retry, 5000)
end

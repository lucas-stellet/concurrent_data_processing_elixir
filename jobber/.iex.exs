good_job = fn ->
  Process.sleep(5000)
  {:ok, []}
end

bad_job = fn ->
  Process.sleep(5000)
  {:error, :long_time_request}
end

doomed_job = fn ->
  Process.sleep(5000)
  raise "Boom!"
end

alias Jobber.JobRegistry

registry_pid = Process.whereis(JobRegistry)
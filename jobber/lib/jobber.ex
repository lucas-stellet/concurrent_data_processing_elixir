defmodule Jobber do
  @moduledoc false

  alias Jobber.{JobRegistry, JobRunner, JobSupervisor}

  def start_job(args) do
    if Enum.count(get_running_jobs("import")) >= 5 do
      {:error, :import_quota_reached}
    else
      DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    end
  end

  def get_running_jobs(type) do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:==, :"$3", type}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]

    Registry.select(JobRegistry, [{match_all, guards, map_result}])
  end
end

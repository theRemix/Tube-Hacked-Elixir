defmodule TubeHacked do
  @otvserver "http://10.0.1.123:8081/bouncer"

  # guess a password between 0-20000, 10 concurrent streams
  @parallel 10
  @batch 2000

  def hackThePlanet do
    Enum.map(0..@parallel, &spawn(fn -> req(&1*@batch, ( &1*@batch )+@batch) end))
  end

  defp req(guess, limit) do
    headers = [{"Content-Type", "application/json"}]
    body = "{\"video_id\": \"1ELVwNAMv2o\",\"username\":\"theRemix💀 and My Pet Coelacanth 🐟\",\"guess\":#{guess}}"
    case HTTPoison.post(@otvserver, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        res(JSON.decode(body), guess, limit)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  # parse body
  # {"success":false,"message":"no sauce for you"}
  defp res({:ok, payload}, guess, limit) do
    success(payload["success"], guess, limit)
  end
  defp res({ :error, actual }, _, _) do
    IO.inspect actual
  end

  defp success(true, _, _) do
    IO.puts "done"
  end
  defp success(false, guess, limit) do
    if guess < limit do
      req guess+1, limit
    end
  end

end

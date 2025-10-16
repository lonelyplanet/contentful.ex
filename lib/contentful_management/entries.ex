defmodule Contentful.Management.Entries do
  alias Contentful.Management
  alias Contentful.Request

  def get_entry(id, opts) do
    space = opts[:space]
    env = opts[:env]
    api_key = opts[:api_key]

    headers =
      Request.headers(api_key)

    url =
      [
        space |> Management.url(env, opts),
        "/entries/",
        id
      ]
      |> Enum.join()
      |> URI.parse()
      |> to_string()

    {url, headers}
    |> Management.get_request()
    |> Management.parse_response(&Contentful.Delivery.Entries.resolve_entity_response/1)
  end

  def update_entry(id, version, payload, opts) do
    space = opts[:space]
    env = opts[:env]
    api_key = opts[:api_key]

    headers =
      Request.headers(api_key) ++
        ["X-Contentful-Version": version]

    url =
      [
        space |> Management.url(env, opts),
        "/entries/",
        id
      ]
      |> Enum.join()
      |> URI.parse()
      |> to_string()

    {url, headers, Jason.encode!(payload)}
    |> Management.put_request()
    |> IO.inspect()
    |> Management.parse_response(&Contentful.Delivery.Entries.resolve_entity_response/1)
  end
end

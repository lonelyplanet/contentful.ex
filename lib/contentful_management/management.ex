defmodule Contentful.Management do
  @moduledoc """
    The Management API is used to manage your contentful data.

    ```
    # config/config.exs
    config :contentful, management: [
      space_id: "<my_space_id>",
      environment: "<my_environment>",
      access_token: "<my_access_token_cma>"
    ]
    ```
  """

  import Contentful.Misc, only: [fallback: 2]

  require Logger

  alias Contentful.Configuration

  @endpoint "api.contentful.com"
  @protocol "https"
  @separator "/"

  @doc """
  Constructs a new Tesla client for requests.

  Can be overridden with a custom client:

  ```
  # config/config.exs
  config :contentful, client: MyApp.CustomClient
  ```
  """
  @spec client :: Tesla.Client.t()
  def client do
    case Contentful.http_client() do
      Tesla -> Tesla.client([Tesla.Middleware.Logger])
      mod -> mod.client()
    end
  end

  @doc """
  Gets the json library for the Contentful Management API based
  on the config/config.exs.

  """
  @spec json_library :: module()
  def json_library do
    Contentful.json_library()
  end

  @doc """
  constructs the base url with protocol for the CMA

  ## Examples

      "https://api.contentful.com" = url()
  """
  @spec url(list()) :: String.t()
  def url(opts \\ []) do
    endpoint = Keyword.get(opts, :endpoint, Configuration.get(:endpoint, :management))

    "#{@protocol}://#{host_from_config(endpoint)}"
  end

  @doc """
  constructs the base url with the space id that got configured in config.exs
  """
  @spec url(nil, list()) :: String.t()
  def url(space, opts) when is_nil(space) do
    case space_from_config() do
      nil ->
        url(opts)

      space ->
        space |> url(opts)
    end
  end

  @doc """
  constructs the base url with the extension for a given space
  ## Examples

      "https://api.contentful.com/spaces/foo" = url("foo")
  """
  @spec url(String.t(), list()) :: String.t()
  def url(space, opts) do
    [url(opts), "spaces", space] |> Enum.join(@separator)
  end

  @doc """
  When explicilty given `nil`, will fetch the `environment` from the environments
  current config (see `config/config.exs`). Will fall back to `"master"` if no environment
  is set.

  ## Examples

    "https://api.contentful.com/spaces/foo/environments/master" = url("foo", nil)

    # With config set in config/config.exs
    config :contentful_delivery, environment: "staging"
    "https://api.contentful.com/spaces/foo/environments/staging" = url("foo", nil)
  """
  @spec url(String.t(), nil, list()) :: String.t()
  def url(space, env, opts) when is_nil(env) do
    [space |> url(opts), "environments", environment_from_config()]
    |> Enum.join(@separator)
  end

  @doc """
  constructs the base url for the delivery endpoint for a given space and environment

  ## Examples

      "https://api.contentful.com/spaces/foo/environments/bar" = url("foo", "bar")
  """
  def url(space, env, opts) do
    [space |> url(opts), "environments", env] |> Enum.join(@separator)
  end

  def get_request({url, headers}) do
    Tesla.get(client(), url, headers: headers)
  end

  @doc """
  Sends a POST request against the CMA. It's really just a wrapper around `Tesla.get/3`
  """
  @spec post_request({binary(), any(), any()}) :: Tesla.Env.result()
  def post_request({url, headers, body}) do
    Tesla.post(client(), url, body, headers: headers)
  end

  @doc """
  Sends a PUT request against the CMA. It's really just a wrapper around `Tesla.put/3`
  """
  @spec put_request({binary(), any(), any()}) :: Tesla.Env.result()
  def put_request({url, headers, body}) do
    Tesla.put(client(), url, body, headers: headers)
  end

  @doc """
  Parses the response from the CMA and triggers a callback on success
  """
  @spec parse_response({:ok, Tesla.Env.t()}, fun()) ::
          {:ok, struct()}
          | {:ok, list(struct()), total: non_neg_integer()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, atom(), original_message: String.t()}
  def parse_response(
        {:ok, %Tesla.Env{status: code, body: body} = resp},
        callback
      ) do
    case code do
      200 ->
        body |> json_library().decode! |> callback.()

      401 ->
        body |> build_error(:unauthorized)

      404 ->
        body |> build_error(:not_found)

      error ->
        Logger.error("Error response: #{inspect(error)}")
        resp |> build_error()
    end
  end

  @doc """
  catch_all for any errors during flight (connection loss, etc.)
  """
  @spec parse_response({:error, any()}, fun()) :: {:error, :unknown}
  def parse_response({:error, error}, _callback) do
    Logger.error("Error response: #{inspect(error)}")
    build_error()
  end

  @doc """
  Used to construct generic errors for calls against the CMA
  """
  @spec build_error(String.t(), atom()) ::
          {:error, atom(), original_message: String.t()}
  def build_error(response_body, status) do
    {:ok, %{"message" => message}} = response_body |> json_library().decode()
    {:error, status, original_message: message}
  end

  @doc """
    Used for the rate limit exceeded error, as it gives the user extra information on wait times
  """
  @spec build_error(Tesla.Env.t()) ::
          {:error, :rate_limit_exceeded, wait_for: integer()}
  def build_error(%Tesla.Env{
        status: 429
      }) do
    {:error, :rate_limit_exceeded, wait_for: 3}
  end

  def build_error(error_response) do
    Logger.error("Error response: #{inspect(error_response)}")

    {:error, :unknown}
  end

  @doc """
    Used to make a generic error, in case the API Response is not what is expected
  """
  @spec build_error() :: {:error, :unknown}
  def build_error do
    {:error, :unknown}
  end

  defp environment_from_config do
    Configuration.get(:environment, :management) |> fallback("master")
  end

  defp space_from_config do
    Configuration.get(:space, :management)
  end

  defp host_from_config(endpoint) do
    case endpoint do
      :management -> @endpoint
      nil -> @endpoint
      value -> value
    end
  end
end

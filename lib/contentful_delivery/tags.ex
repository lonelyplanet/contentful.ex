defmodule Contentful.Delivery.Tags do
  @moduledoc """
  Tags allows for querying the tags of a space via `Contentful.Query`.
  """

  alias Contentful.{Tag, Queryable}

  @behaviour Queryable

  @endpoint "/tags"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(%{"items" => items}) do
    tags =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, tag} -> tag end)

    {:ok, tags}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "sys" => sys,
        "name" => name
      }) do
    {:ok,
     %Tag{
       sys: sys,
       name: name
     }}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "sys" => sys,
        "name" => name
      }) do
    {:ok,
     %Tag{
       sys: sys,
       name: name
     }}
  end
end

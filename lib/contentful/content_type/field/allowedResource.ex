defmodule Contentful.ContentType.Field.AllowedResource do
  @moduledoc """
  Represents single item of `allowedResources` list in the `Contentful.ContentType.Field` struct.

  Set when type is "ResourceLink".

  Example:

  ```elixir
  %Contentful.ContentType.Field.AllowedResource{
    type: "Contentful:Entry",
    source: "crn:contentful:::content:spaces/id/environments/staging",
    content_types: [
      "assembly"
    ]
  }
  ```
  """

  defstruct [
    :type,
    :source,
    :content_types
  ]

  @type t :: %__MODULE__{
          type: String.t(),
          source: String.t(),
          content_types: list(String.t())
        }

  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      type: attrs["type"],
      source: attrs["source"],
      content_types: attrs["contentTypes"]
    }
  end
end

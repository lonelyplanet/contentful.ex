defmodule Contentful.ContentType.Field.Items do
  @moduledoc """
  Represents `items` field in the `Contentful.ContentType.Field` struct.

  Set when type is "Link".

  Example:

  ```elixir
  %Contentful.ContentType.Field.Items{
    type: "Link",
    validations: [
      %{
        linkContentType: [
          "assembly"
        ]
      }
    ],
    link_type: "Entry"
  }
  ```
  """

  defstruct [
    :type,
    :validations,
    :link_type
  ]

  @type t :: %__MODULE__{
          type: String.t(),
          validations: list(map()) | nil,
          link_type: String.t() | nil
        }

  @spec new(map() | nil) :: t() | nil
  def new(nil), do: nil

  def new(attrs) do
    %__MODULE__{
      type: attrs["type"],
      validations: attrs["validations"],
      link_type: attrs["linkType"]
    }
  end
end

defmodule Contentful.ContentType.Field do
  @moduledoc """
  Represents a single field in the field defintion of a `Contentful.ContentType`.

  See the [content model documentation for more information](https://www.contentful.com/developers/docs/concepts/data-model/)

  """

  defstruct [
    :id,
    :name,
    :type,
    :localized,
    :required,
    :disabled,
    :omitted,
    :items, # for type "Link"
    :allowed_resources # for type "ResourceLink"
  ]

  alias Contentful.ContentType.Field.Items
  alias Contentful.ContentType.Field.AllowedResource

  @type t :: %Contentful.ContentType.Field{
          id: String.t(),
          name: String.t(),
          type: String.t(),
          localized: boolean(),
          required: boolean(),
          disabled: boolean(),
          omitted: boolean(),
          items: Items.t() | nil,
          allowed_resources: [AllowedResource.t()] | nil
        }

  @spec new(map()) :: t()
  def new(attrs) do
    allowed_resourced =
      if is_list(attrs["allowedResources"]),
        do: Enum.map(attrs["allowedResources"], &AllowedResource.new/1),
        else: nil

    %__MODULE__{
      id: attrs["id"],
      name: attrs["name"],
      type: attrs["type"],
      localized: attrs["localized"],
      required: attrs["required"],
      disabled: attrs["disabled"],
      omitted: attrs["omitted"],
      items: Items.new(attrs["items"]),
      allowed_resources: allowed_resourced
    }
  end
end

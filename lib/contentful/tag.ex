defmodule Contentful.Tag do
  defstruct [:sys, :name]

  @type t :: %Contentful.Tag{
          sys: %Contentful.SysData{},
          name: String.t()
        }
end

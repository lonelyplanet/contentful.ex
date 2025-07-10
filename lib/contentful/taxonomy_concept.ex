defmodule Contentful.TaxonomyConcept do
  defstruct [:sys]

  @type t :: %Contentful.TaxonomyConcept{
          sys: %Contentful.SysData{}
        }
end

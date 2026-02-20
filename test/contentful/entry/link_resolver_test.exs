defmodule Contentful.Entry.LinkResolverTest do
  use ExUnit.Case

  alias Contentful.Asset
  alias Contentful.{ContentType, Entry, SysData}
  alias Contentful.Entry.LinkResolver

  describe "replace_links_with_entities/2" do
    test "Entry with no links returns unchanged Entry" do
      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "facebook" => "johndoe"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "updatedAt" => "2020-04-18T18:44:10.435Z"
            }
          }
        ]
      }

      %Entry{} = %Entry{} |> LinkResolver.replace_links_with_entities(includes)
    end

    test "empty includes returns unchanged Entry" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Entry",
              "type" => "Link"
            }
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      ^entry = entry |> LinkResolver.replace_links_with_entities(%{})
    end

    test "links found in 'includes' are resolved in entry, others not found are left unchanged" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Entry",
              "type" => "Link"
            }
          },
          "heroImage" => %{
            "sys" => %{
              "id" => "4NzwDSDlGECGIiokKomsyI",
              "linkType" => "Asset",
              "type" => "Link"
            }
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "name" => "John Doe"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "revision" => 2,
              "createdAt" => "2019-03-22T08:33:44.329Z",
              "updatedAt" => "2020-04-18T18:44:10.435Z",
              "locale" => "en-US"
            },
            "metadata" => %{"tags" => []}
          }
        ]
      }

      %Entry{
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          created_at: "2019-03-22T08:33:45.069Z",
          updated_at: "2020-04-18T18:44:10.843Z",
          locale: "en-US",
          content_type: %ContentType{
            id: "blogPost"
          }
        },
        fields: %{
          "author" => %Entry{
            sys: %SysData{
              id: "15jwOBqpxqSAOy2eOO4S0m",
              revision: 2,
              created_at: "2019-03-22T08:33:44.329Z",
              updated_at: "2020-04-18T18:44:10.435Z",
              locale: "en-US",
              content_type: %ContentType{
                id: "person"
              }
            },
            fields: %{"company" => "ACME", "email" => "john@doe.com", "name" => "John Doe"}
          },
          "heroImage" => %{
            "sys" => %{
              "id" => "4NzwDSDlGECGIiokKomsyI",
              "linkType" => "Asset",
              "type" => "Link"
            }
          }
        }
      } = entry |> LinkResolver.replace_links_with_entities(includes)
    end

    test "resolves links nested in complex fields" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Entry",
              "type" => "Link"
            }
          },
          "description" => %{
            "content" => [
              %{
                "content" => [
                  %{
                    "data" => %{},
                    "marks" => [],
                    "nodeType" => "text",
                    "value" => "as seen in Zoolander."
                  }
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              },
              %{
                "content" => [],
                "data" => %{
                  "target" => %{
                    "sys" => %{
                      "id" => "7orLdboQQowIUs22KAW4U",
                      "linkType" => "Asset",
                      "type" => "Link"
                    }
                  }
                },
                "nodeType" => "embedded-asset-block"
              },
              %{
                "content" => [
                  %{"data" => %{}, "marks" => [], "nodeType" => "text", "value" => ""}
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              }
            ],
            "data" => %{},
            "nodeType" => "document"
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "name" => "John Doe",
              "image" => %{
                "sys" => %{
                  "type" => "Link",
                  "linkType" => "Asset",
                  "id" => "7orLdboQQowIUs22KAW4U"
                }
              }
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "revision" => 2,
              "createdAt" => "2019-03-22T08:33:44.329Z",
              "updatedAt" => "2020-04-18T18:44:10.435Z",
              "locale" => "en-US"
            },
            "metadata" => %{"tags" => []}
          }
        ],
        "Asset" => [
          %{
            "metadata" => %{
              "tags" => []
            },
            "sys" => %{
              "space" => %{
                "sys" => %{
                  "type" => "Link",
                  "linkType" => "Space",
                  "id" => "gtrsnz13drim"
                }
              },
              "id" => "7orLdboQQowIUs22KAW4U",
              "type" => "Asset",
              "createdAt" => "2019-03-22T08:33:38.110Z",
              "updatedAt" => "2020-04-18T18:44:04.820Z",
              "environment" => %{
                "sys" => %{
                  "id" => "master",
                  "type" => "Link",
                  "linkType" => "Environment"
                }
              },
              "revision" => 2,
              "locale" => "en-US"
            },
            "fields" => %{
              "title" => "Sparkler",
              "description" => "John with Sparkler",
              "file" => %{
                "url" =>
                  "//images.ctfassets.net/gtrsnz13drim/7orLdboQQowIUs22KAW4U/ae1e04accdfcf6c3def7a449d12bff4c/matt-palmer-254999.jpg",
                "details" => %{
                  "size" => 2_293_094,
                  "image" => %{
                    "width" => 3000,
                    "height" => 2000
                  }
                },
                "fileName" => "matt-palmer-254999.jpg",
                "contentType" => "image/jpeg"
              }
            }
          }
        ]
      }

      %Entry{
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          created_at: "2019-03-22T08:33:45.069Z",
          updated_at: "2020-04-18T18:44:10.843Z",
          locale: "en-US",
          content_type: %ContentType{
            id: "blogPost"
          }
        },
        fields: %{
          "author" => %Entry{
            sys: %SysData{
              id: "15jwOBqpxqSAOy2eOO4S0m",
              revision: 2,
              created_at: "2019-03-22T08:33:44.329Z",
              updated_at: "2020-04-18T18:44:10.435Z",
              locale: "en-US",
              content_type: %ContentType{
                id: "person"
              }
            },
            fields: %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "name" => "John Doe",
              "image" => %Asset{
                sys: %SysData{
                  id: "7orLdboQQowIUs22KAW4U"
                },
                fields: %Asset.Fields{
                  title: "Sparkler",
                  description: "John with Sparkler",
                  file: %{
                    content_type: "image/jpeg",
                    details: %{
                      "image" => %{
                        "height" => 2000,
                        "width" => 3000
                      },
                      "size" => 2_293_094
                    },
                    file_name: "matt-palmer-254999.jpg",
                    url: %URI{
                      host: "images.ctfassets.net",
                      path:
                        "/gtrsnz13drim/7orLdboQQowIUs22KAW4U/ae1e04accdfcf6c3def7a449d12bff4c/matt-palmer-254999.jpg"
                    }
                  }
                }
              }
            }
          },
          "description" => %{
            "content" => [
              %{
                "content" => [
                  %{
                    "data" => %{},
                    "marks" => [],
                    "nodeType" => "text",
                    "value" => "as seen in Zoolander."
                  }
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              },
              %{
                "content" => [],
                "data" => %{
                  "target" => %Asset{
                    sys: %SysData{
                      id: "7orLdboQQowIUs22KAW4U"
                    },
                    fields: %Asset.Fields{
                      title: "Sparkler",
                      description: "John with Sparkler",
                      file: %{
                        content_type: "image/jpeg",
                        details: %{
                          "image" => %{
                            "height" => 2000,
                            "width" => 3000
                          },
                          "size" => 2_293_094
                        },
                        file_name: "matt-palmer-254999.jpg",
                        url: %URI{
                          host: "images.ctfassets.net",
                          path:
                            "/gtrsnz13drim/7orLdboQQowIUs22KAW4U/ae1e04accdfcf6c3def7a449d12bff4c/matt-palmer-254999.jpg"
                        }
                      }
                    }
                  }
                },
                "nodeType" => "embedded-asset-block"
              },
              %{
                "content" => [
                  %{"data" => %{}, "marks" => [], "nodeType" => "text", "value" => ""}
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              }
            ],
            "data" => %{},
            "nodeType" => "document"
          }
        }
      } = entry |> LinkResolver.replace_links_with_entities(includes)
    end

    test "ignores unknown LinkTypes we don't know how to parse even if matching entity exists in includes" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Unknown",
              "type" => "Link"
            }
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      includes = %{
        "Unknown" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "facebook" => "johndoe"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "updatedAt" => "2020-04-18T18:44:10.435Z"
            }
          }
        ]
      }

      ^entry = entry |> LinkResolver.replace_links_with_entities(includes)
    end

    test "resolves nested links within lists of Entries" do
      entry = %Entry{
        fields: %{
          "blocks" => [
            %{
              "sys" => %{
                "id" => "2IqBemFvusQUTEcnB93jDO",
                "linkType" => "Entry",
                "type" => "Link"
              }
            }
          ],
          "slug" => "my-page-with-content-blocks",
          "title" => "My Page with Content Blocks"
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "page"}
        }
      }

      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "features" => [
                %{
                  "sys" => %{
                    "id" => "7nPDsIzj69Ey8RRvjRh5yT",
                    "linkType" => "Entry",
                    "type" => "Link"
                  }
                },
                %{
                  "sys" => %{
                    "id" => "2VzTGEENSvxVZbfnxDJv2C",
                    "linkType" => "Entry",
                    "type" => "Link"
                  }
                }
              ],
              "title" => "Some features"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "blockIcons",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "createdAt" => "2024-04-27T13:09:31.838Z",
              "id" => "2IqBemFvusQUTEcnB93jDO",
              "locale" => "en-GB",
              "revision" => 1,
              "type" => "Entry",
              "updatedAt" => "2024-04-27T13:55:14.757Z"
            },
            "metadata" => %{"tags" => []}
          },
          %{
            "fields" => %{
              "iconEmoji" => "😋",
              "title" => "It is tasty"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "componentFeatures",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "createdAt" => "2024-04-27T13:50:54.844Z",
              "id" => "2VzTGEENSvxVZbfnxDJv2C",
              "locale" => "en-GB",
              "revision" => 1,
              "type" => "Entry",
              "updatedAt" => "2024-04-27T13:51:11.254Z"
            },
            "metadata" => %{"tags" => []}
          },
          %{
            "fields" => %{
              "iconEmoji" => "🥳",
              "title" => "It is fun"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "componentFeatures",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "createdAt" => "2024-04-27T13:49:44.958Z",
              "id" => "7nPDsIzj69Ey8RRvjRh5yT",
              "locale" => "en-GB",
              "revision" => 1,
              "type" => "Entry",
              "updatedAt" => "2024-04-27T13:50:40.939Z"
            },
            "metadata" => %{"tags" => []}
          }
        ]
      }

      %Entry{
        fields: %{
          "blocks" => [
            %Entry{
              fields: %{
                "features" => [
                  %Entry{
                    fields: %{
                      "iconEmoji" => "🥳",
                      "title" => "It is fun"
                    }
                  },
                  %Entry{
                    fields: %{
                      "iconEmoji" => "😋",
                      "title" => "It is tasty"
                    }
                  }
                ]
              }
            }
          ],
          "slug" => "my-page-with-content-blocks",
          "title" => "My Page with Content Blocks"
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "page"}
        }
      } = LinkResolver.replace_links_with_entities(entry, includes)
    end
  end

  describe "global resolution cache" do
    defp make_entry_include(id, content_type_id, fields) do
      %{
        "fields" => fields,
        "sys" => %{
          "contentType" => %{
            "sys" => %{"id" => content_type_id, "linkType" => "ContentType", "type" => "Link"}
          },
          "id" => id,
          "type" => "Entry",
          "revision" => 1,
          "createdAt" => "2024-01-01T00:00:00.000Z",
          "updatedAt" => "2024-01-01T00:00:00.000Z",
          "locale" => "en-US"
        },
        "metadata" => %{"tags" => []}
      }
    end

    defp make_link(id), do: %{"sys" => %{"id" => id, "linkType" => "Entry", "type" => "Link"}}

    defp make_root_entry(id, content_type_id, fields) do
      %Entry{
        fields: fields,
        sys: %SysData{
          id: id,
          revision: 1,
          locale: "en-US",
          updated_at: "2024-01-01T00:00:00.000Z",
          created_at: "2024-01-01T00:00:00.000Z",
          content_type: %ContentType{id: content_type_id}
        }
      }
    end

    test "caches resolved entries so the same entry is not re-resolved from a different branch" do
      entry = make_root_entry("article", "article", %{
        "pois" => [make_link("poi_a"), make_link("poi_b")]
      })

      includes = %{
        "Entry" => [
          make_entry_include("poi_a", "poi", %{
            "name" => "POI A",
            "place" => make_link("barcelona")
          }),
          make_entry_include("poi_b", "poi", %{
            "name" => "POI B",
            "place" => make_link("barcelona")
          }),
          make_entry_include("barcelona", "place", %{
            "name" => "Barcelona",
            "country" => "Spain"
          })
        ]
      }

      result = LinkResolver.replace_links_with_entities(entry, includes)

      [resolved_a, resolved_b] = result.fields["pois"]

      assert %Entry{fields: %{"name" => "Barcelona", "country" => "Spain"}} =
               resolved_a.fields["place"]

      assert %Entry{fields: %{"name" => "Barcelona", "country" => "Spain"}} =
               resolved_b.fields["place"]

      assert resolved_a.fields["place"] == resolved_b.fields["place"]
    end

    test "process dictionary cache is cleaned up after resolution" do
      entry = make_root_entry("entry_1", "article", %{"title" => "Hello"})

      LinkResolver.replace_links_with_entities(entry, %{})

      assert Process.get(:contentful_resolved_cache) == nil
    end

    test "circular references between entries are handled without infinite recursion" do
      entry = make_root_entry("article", "article", %{
        "poi" => make_link("poi_a")
      })

      includes = %{
        "Entry" => [
          make_entry_include("poi_a", "poi", %{
            "name" => "POI A",
            "related" => make_link("poi_b")
          }),
          make_entry_include("poi_b", "poi", %{
            "name" => "POI B",
            "related" => make_link("poi_a")
          })
        ]
      }

      result = LinkResolver.replace_links_with_entities(entry, includes)

      resolved_a = result.fields["poi"]
      assert %Entry{fields: %{"name" => "POI A"}} = resolved_a

      resolved_b = resolved_a.fields["related"]
      assert %Entry{fields: %{"name" => "POI B"}} = resolved_b

      # POI B's back-reference to POI A is returned as-is (cycle detection stops recursion),
      # so its sub-fields are not recursively resolved
      back_ref = resolved_b.fields["related"]
      assert %Entry{fields: %{"name" => "POI A"}} = back_ref
    end

    test "many cross-linked entries resolve in bounded time (O(N) not O(N!))" do
      n = 30
      poi_ids = for i <- 1..n, do: "poi_#{i}"

      poi_links = Enum.map(poi_ids, &make_link/1)

      barcelona =
        make_entry_include("barcelona", "place", %{
          "name" => "Barcelona",
          "pois" => poi_links
        })

      poi_includes =
        Enum.map(poi_ids, fn id ->
          make_entry_include(id, "poi", %{
            "name" => "POI #{id}",
            "place" => make_link("barcelona")
          })
        end)

      includes = %{"Entry" => [barcelona | poi_includes]}

      entry = make_root_entry("article", "article", %{"pois" => poi_links})

      {time_us, result} =
        :timer.tc(fn ->
          LinkResolver.replace_links_with_entities(entry, includes)
        end)

      assert time_us < 1_000_000, "Expected < 1s, took #{time_us / 1_000}ms"

      resolved_pois = result.fields["pois"]
      assert length(resolved_pois) == n

      for poi <- resolved_pois do
        assert %Entry{} = poi
        assert %Entry{fields: %{"name" => "Barcelona"}} = poi.fields["place"]
      end
    end
  end
end

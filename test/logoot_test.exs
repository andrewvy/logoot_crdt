defmodule LogootTest do
  use ExUnit.Case
  doctest Logoot

  test "Bare-bones document contains the two boundary min/max items" do
    document = Logoot.Document.new()

    first_item = document.items |> Enum.at(0)
    last_item = document.items |> Enum.at(-1)

    assert first_item.pid.positions |> Enum.count() == 1
    assert last_item.pid.positions |> Enum.count() == 1
  end

  test "Can create and insert into document" do
    document = Logoot.Document.new()
    site_id = 1
    clock = 1
    item = %Logoot.Item{
      pid: %Logoot.Pid{
        clock: clock
      },
      content: "My content!"
    }

    # Insert in-between the two boundary items.
    new_document = document |> Logoot.insert_item(item, 1, site_id)

    # Expect the new item to be between the two boundary items.
    assert Enum.at(new_document.items, 1).content == item.content
  end

  test "Can insert in a more complex document" do
    document = %Logoot.Document{
      items: [
        %Logoot.Item{
          pid: %Logoot.Pid{
            positions: [Logoot.Identifier.min()]
          }
        },
        %Logoot.Item{
          pid: %Logoot.Pid{
            positions: [
              %Logoot.Identifier{integer: 1, site_identifier: 1},
              %Logoot.Identifier{integer: 3, site_identifier: 2}
            ]
          },
          content: "This is line 1 from Site 2!"
        },
        %Logoot.Item{
          pid: %Logoot.Pid{
            positions: [
              %Logoot.Identifier{integer: 1, site_identifier: 1},
              %Logoot.Identifier{integer: 5, site_identifier: 5}
            ]
          },
          content: "This is line 2 from Site 5!"
        },
        %Logoot.Item{
          pid: %Logoot.Pid{
            positions: [Logoot.Identifier.max()]
          }
        }
      ]
    }

    item = %Logoot.Item{
      content: "My new content from Site 10!"
    }

    # Insert in-between the two items.
    new_document = document |> Logoot.insert_item(item, 2, 10)
    %Logoot.Item{pid: %Logoot.Pid{positions: expected_positions}} = expected_item = Enum.at(new_document.items, 2)

    # Expect the new item to be between the two boundary items.
    assert expected_item.content == item.content

    # First position should be (1, 1)
    assert expected_positions |> Enum.at(0) == %Logoot.Identifier{
      integer: 1,
      site_identifier: 1
    }

    # Next position should be from our site id 10
    assert (expected_positions |> Enum.at(1)).site_identifier == 10
 end

  test "An unordered document returns an error" do
    # This document is unordered because the identifier positions are not in order.
    unordered_document =
      %Logoot.Document{
        items: [
          %Logoot.Item{
            pid: %Logoot.Pid{
              positions: [%Logoot.Identifier{integer: 1}]
            }
          },
          %Logoot.Item{
            pid: %Logoot.Pid{
              positions: [%Logoot.Identifier{integer: 0}]
            }
          }
        ]
      }

    item = %Logoot.Item{
      pid: %Logoot.Pid{
        clock: 1
      },
      content: "My content!"
    }

    # Insert in-between the two boundary items, but should fail
    # because our document is out-of-order.
    assert_raise RuntimeError, "Document is unordered!", fn() ->
      unordered_document |> Logoot.insert_item(item, 1, 1)
    end
  end
end

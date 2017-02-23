defmodule Logoot.Identifier do
  defstruct integer: 0, site_identifier: 0

  @min_integer 0
  @max_integer 32676

  def min() do
    %__MODULE__{
      integer: @min_integer
    }
  end

  def max() do
    %__MODULE__{
      integer: @max_integer
    }
  end
end

defmodule Logoot.Pid do
  defstruct positions: [], clock: 0
end

defmodule Logoot.Item do
  defstruct pid: %Logoot.Pid{}, content: ""
end

defmodule Logoot.Document do
  defstruct items: []

  def new() do
    %__MODULE__{
      items: [
        %Logoot.Item{
          pid: %Logoot.Pid{
            positions: [Logoot.Identifier.min()]
          }
        },
        %Logoot.Item{
          pid: %Logoot.Pid{
            positions: [Logoot.Identifier.max()]
          }
        }
      ]
    }
  end
end

defmodule Logoot do
  @moduledoc """
  This is the main module for manipulating Logoot documents.
  """

  alias Logoot.{Document, Identifier, Item}

  @doc """
  Insert an %Item{} into a given document at a specific line index.
  """
  def insert_item(%Document{} = document, %Item{} = item, line_index, site_identifier) do
    previous_item =
      document.items
      |> Enum.at(line_index - 1)

    next_item =
      document.items
      |> Enum.at(line_index)

    cond do
      is_nil(previous_item) or is_nil(next_item) -> :error
      true ->
        new_positions =
          Enum.zip(previous_item.pid.positions, next_item.pid.positions)
          |> Enum.reduce_while([], fn({position_a, position_b}, acc) ->
            case compare_identifiers(position_a, position_b) do
              # @todo(vy): Make this return an :error instead
              :lt -> raise "Document is unordered!"
              :gt -> {:cont, [generate_identifier(position_a, position_b, site_identifier) | acc]}
              :eq -> {:cont, [position_a | acc]}
            end
          end)
          |> Enum.reverse()

        item_to_insert = %Item{
          item |
          pid: Map.put(item.pid, :positions, new_positions)
        }

        document
        |> Map.put(:items, List.insert_at(document.items, line_index, item_to_insert))
    end
  end

  def generate_identifier(%Identifier{} = identifier_a, %Identifier{} = identifier_b, site_identifier) do
    %Identifier{
      integer: generate_random_integer_between(identifier_a.integer, identifier_b.integer),
      site_identifier: site_identifier
    }
  end

  def compare_identifiers(%Identifier{} = identifier_a, %Identifier{} = identifier_b) do
    cond do
      identifier_a.integer > identifier_b.integer -> :lt
      identifier_a.integer < identifier_b.integer -> :gt
      identifier_a.site_identifier > identifier_b.site_identifier -> :lt
      identifier_a.site_identifier < identifier_b.site_identifier -> :gt
      true -> :eq
    end
  end

  def generate_random_integer_between(min, max) do
    :rand.uniform(max - min) + min
  end
end

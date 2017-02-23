# Logoot

[Logoot CRDT](https://hal.archives-ouvertes.fr/inria-00432368/document) implementation in Elixir.

**DO NOT USE**: This is still a WIP and requires testing + documentation.

```elixir
document = Logoot.Document.new()
item = %Logoot.Item{
  content: "Hello world!"
}

# Insert a new line at index 1.
document
|> Logoot.insert_item(item, 1, site_id)
```

defmodule TodoList do
  defmodule CsvImporter do
    def import(filename) do
      filename
      |> read_lines
      |> to_entries
      # ["2018/12/19,Dentist", "2018/12/20,Shopping", "2018/12/19,Movies"]
      |> TodoList.new
      |> IO.inspect

      # def a(arr) do
      #   %{date: arr[0], title: arr[1]}
      # end
    end

    defp read_lines(file) do
      file
      |> File.stream!
      |> Stream.map(&String.trim/1)
    end

    defp to_entries(lines) do
      lines
      |> Stream.map(&convert/1)
    end

    defp convert(string) do
      string
      |> String.split(",")
      |> convert_date
      |> to_entry
    end

    defp convert_date([date, title]) do
      [c(date), title]
    end

    defp c(str) do
      String.replace(str, "/", "-")
      |> Date.from_iso8601!()
    end

    defp to_entry([date, title]) do
      %{date: date, title: title}
    end
  end


  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(todo_list.entries, entry.id, entry)

    %TodoList{todo_list | auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = %{} = fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end

# todo_list =
#   TodoList.new()
#   |> TodoList.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
#   |> TodoList.add_entry(%{date: ~D[2019-12-19], title: "Dentist"})

# TodoList.update_entry(
#   todo_list,
#   1,
#   &Map.put(&1, :date, ~D[2018-12-20])
# )

# %TodoList{
#   auto_id: 3,
#   entries: %{
#     1 => %{date: ~D[2018-12-19], id: 1, title: "Dentist"},
#     2 => %{date: ~D[2018-12-19], id: 2, title: "Dentist"}
#   }
# }

# entries = [
#   %{date: ~D[2018-12-19], title: "Dentist"},
#   %{date: ~D[2018-12-20], title: "Shopping"},
#   %{date: ~D[2018-12-19], title: "Movies"}
# ]

TodoList.CsvImporter.import("todos.csv")

defrecord ExQL.Select, dict: [fields: :*] do
  use ExQL.Query

  accessor :fields
  accessor :from
  accessor :where

  def statement(:modifiers, query) do
    ExQL.Expression.join(dict(query)[:modifiers], :raw, " ")
  end

  def statement(:fields, query) do
    ExQL.Expression.join(dict(query)[:fields], :raw, ",")
  end

  def statement(:from, query) do
    ["FROM", ExQL.Expression.join(dict(query)[:from], :raw, ",")]
  end

  def statement(:where, query) do
    case dict(query)[:where] do
      nil -> nil
      conds -> ["WHERE", ExQL.Expression.join(conds, :value, "AND")]
    end
  end

  def statement(:group, query) do
    case dict(query)[:group] do
      nil -> nil
      group_by -> ["GROUP BY", ExQL.Expression.join(group_by, :raw, ",")]
    end
  end

  def statement(query) do
    ["SELECT", statement(:modifiers, query), statement(:fields, query),
    statement(:from, query), statement(:where, query), statement(:group, query)] /> ExQL.Utils.space
  end
end

defimpl Binary.Inspect, for: ExQL.Select do 
  def inspect(thing), do: statement(thing.statement, [])

  defp statement([], acc), do: iolist_to_binary(List.reverse(acc))
  defp statement([{:value, value}|rest], acc) do
    statement(rest, [Binary.Inspect.inspect(value)|acc])
  end
  defp statement([list|rest], acc) when is_list(list) do
    new_acc = statement(list, [])
    statement(rest, [new_acc|acc])
  end
  defp statement([head|rest], acc) do
    statement(rest, [head|acc])
  end

end
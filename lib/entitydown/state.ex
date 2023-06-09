defmodule Entitydown.State do
  @moduledoc false

  alias Entitydown.Node

  defmodule Line do
    @moduledoc false

    defstruct [:src, :len]

    @type t :: %__MODULE__{
            src: binary,
            len: non_neg_integer
          }

    def new(src) do
      %__MODULE__{
        src: src,
        len: String.length(src)
      }
    end
  end

  defstruct [:line, :pos, nodes: []]

  @type t :: %__MODULE__{
          line: Line.t(),
          pos: non_neg_integer,
          nodes: [Node.t()]
        }

  def add_node(state, node) do
    nodes = state.nodes ++ [node]

    %{state | nodes: nodes}
  end

  def read_normal_char(state) do
    r =
      case List.last(state.nodes) do
        %{type: nil} = node ->
          children = node.children <> String.slice(state.line.src, state.pos, 1)

          {:updated, %{node | children: children}}

        _node ->
          {:added, %Node{type: nil, children: String.slice(state.line.src, state.pos, 1)}}
      end

    nodes =
      case r do
        {:updated, node} ->
          List.update_at(state.nodes, -1, fn _node -> node end)

        {:added, node} ->
          state.nodes ++ [node]
      end

    %{state | nodes: nodes, pos: state.pos + 1}
  end

  def add_line_break(state) do
    nodes = state.nodes ++ [%Node{children: "\n"}]

    %{state | nodes: nodes, pos: state.pos + 1}
  end

  def update_pos(state, pos) do
    %{state | pos: pos}
  end
end

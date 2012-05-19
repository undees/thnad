require 'gritty'

def dump(obj, name)
  g = digraph do
    graph_attribs << 'bgcolor=black'

    node_attribs << 'color=white'
    node_attribs << 'penwidth=2'
    node_attribs << 'fontcolor=white'
    node_attribs << 'labelloc=c'
    node_attribs << 'fontname="Courier New"'
    node_attribs << 'fontsize=36'

    edge_attribs << 'color=white'
    edge_attribs << 'penwidth=2'

    builder = Gritty::NodeBuilder.new self
    builder.build obj, 'root'

    save name, 'pdf'
  end
end

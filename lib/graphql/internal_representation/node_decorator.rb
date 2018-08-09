# frozen_string_literal: true

GraphQL::InternalRepresentation::Node.class_eval do
  def all_nodes(node = nil)
    node = node.nil? ? self : node
    nodes = {}
    if node.typed_children.any?
      nodes[node.name] = []
      node.typed_children.each do |_type, children|
        children.each do |_name, child|
          nodes[node.name] << all_nodes(child)
        end
      end
    elsif node.definition
      return node.name if node.name == node.definition_name
    end
    nodes
  end
end

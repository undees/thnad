require 'parslet'
require 'thnad/nodes'

module Thnad
  class Transform < Parslet::Transform
    rule(:number => simple(:value)) { Number.new(value.to_i) }
  end
end

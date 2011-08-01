require 'parslet'

module Thnad
  class Parser < Parslet::Parser
    rule(:number) { match('[0-9]').repeat(1).as(:number) >> space? }
    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { space.maybe }

    rule(:root)   { number }
  end
end

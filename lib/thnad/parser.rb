require 'parslet'

module Thnad
  class Parser < Parslet::Parser
    rule(:name)   { match('[a-z]').repeat(1).as(:name) >> space? }
    rule(:number) { match('[0-9]').repeat(1).as(:number) >> space? }
    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { space.maybe }

    rule(:args) {
      lparen >>
      ((expression.as(:arg) >> (comma >> expression.as(:arg)).repeat(0)).maybe).as(:args) >>
      rparen
    }

    rule(:expression) { funcall | number | name }

    rule(:lparen) { str('(') >> space? }
    rule(:rparen) { str(')') >> space? }
    rule(:comma)  { str(',') >> space? }

    rule(:funcall) { name.as(:funcall) >> args }

    rule(:root)   { expression }
  end
end

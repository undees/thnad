require 'parslet'
require 'thnad/nodes'

module Thnad
  class Transform < Parslet::Transform
    rule(:number => simple(:value)) { Number.new(value.to_i) }
    rule(:name   => simple(:name))  { Name.new(name.to_s) }

    rule(:arg  => simple(:arg))    { arg  }
    rule(:args => sequence(:args)) { args }

    rule(:funcall => simple(:funcall),
         :args    => simple(:args))   { Funcall.new(funcall.name, [args]) }

    rule(:funcall => simple(:funcall),
         :args    => sequence(:args)) { Funcall.new(funcall.name, args) }

    rule(:cond     => simple(:cond),
         :if_true  => {:body => simple(:if_true)},
         :if_false => {:body => simple(:if_false)}) { Conditional.new(cond, if_true, if_false) }

    rule(:param  => simple(:param))    { param  }
    rule(:params => sequence(:params)) { params }

    rule(:func   => simple(:func),
         :params => simple(:name),
         :body   => simple(:body)) { Function.new(func.name, [name], body) }

    rule(:func   => simple(:func),
         :params => sequence(:params),
         :body   => simple(:body)) { Function.new(func.name, params, body) }
  end
end

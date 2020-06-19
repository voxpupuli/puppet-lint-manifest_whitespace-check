# frozen_string_literal: true

def is_single_space(token)
  token.type == :WHITESPACE && token.value == ' '
end

def new_single_space
  PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0)
end

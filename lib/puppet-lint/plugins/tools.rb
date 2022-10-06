# frozen_string_literal: true

def is_single_space(token)
  token.type == :WHITESPACE && token.value == ' '
end

def new_single_space
  PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0)
end

def after_bracket_tokens
  %i[RBRACK RPAREN SEMIC COMMA COLON DOT NEWLINE DQMID DQPOST LBRACK HEREDOC_MID HEREDOC_POST]
end

def prev_non_space_token(token)
  while token = token.prev_token
    return token unless %i[WHITESPACE INDENT NEWLINE].include?(token.type)
  end
end

def next_non_space_token(token)
  while token = token.next_token
    return token unless %i[WHITESPACE INDENT NEWLINE].include?(token.type)
  end
end

# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_arrows_single_space_after) do
  def check
    tokens.select { |token| token.type == :FARROW }.each do |token|
      next_token = token.next_token

      next unless next_token && next_token.value != ' '

      notify(
        :error,
        message: 'there should be a single space after an arrow',
        line: next_token.line,
        column: next_token.column,
        token: next_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]

    if token.type == :WHITESPACE
      token.value = ' '
      return
    end

    add_token(tokens.index(token), PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0))
  end
end

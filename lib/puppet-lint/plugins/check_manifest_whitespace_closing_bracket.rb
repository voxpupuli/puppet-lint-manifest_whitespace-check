# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_closing_bracket_before) do
  def check
    tokens.select { |token| token.type == :RBRACK }.each do |bracket_token|
      prev_token = bracket_token.prev_token
      next unless prev_token

      prev_code_token = prev_non_space_token(bracket_token)
      next unless prev_code_token

      next unless %i[NEWLINE INDENT WHITESPACE].include?(prev_token.type)

      next if prev_token.type == :INDENT && (tokens.index(prev_code_token) == tokens.index(bracket_token) - 3)
      next if prev_token.type == :NEWLINE && (tokens.index(prev_code_token) == tokens.index(bracket_token) - 2)

      notify(
        :error,
        message: 'there should be no whitespace or a single newline before a closing bracket',
        line: prev_code_token.next_token.line,
        column: prev_code_token.next_token.column,
        token: prev_code_token.next_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    if token.type == :WHITESPACE
      remove_token(token)
      return
    end

    next_token = token.next_token
    until next_token.type == :RBRACK
      break if next_token.type == :INDENT && next_token.next_token.type == :RBRACK

      remove_token(next_token)
      next_token = next_token.next_token
    end
  end
end

PuppetLint.new_check(:manifest_whitespace_closing_bracket_after) do
  def check
    tokens.select { |token| token.type == :RBRACK }.each do |bracket_token|
      next_token = bracket_token.next_token

      next unless next_token
      next if after_bracket_tokens.include?(next_token.type)

      if next_token.type == :WHITESPACE
        next_code_token = next_non_space_token(bracket_token)
        next unless next_code_token
        next unless after_bracket_tokens.include?(next_code_token.type)
      end

      notify(
        :error,
        message: 'there should be either a bracket, punctuation mark, closing quote or a newline after a closing bracket, or whitespace and none of the aforementioned',
        line: next_token.line,
        column: next_token.column,
        token: next_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]

    next_token = token

    until %i[RBRACE RBRACK RPAREN COMMA NEWLINE].include?(next_token.type)
      raise PuppetLint::NoFix if next_token.type != :WHITESPACE

      remove_token(next_token)
      next_token = next_token.next_token
    end
  end
end

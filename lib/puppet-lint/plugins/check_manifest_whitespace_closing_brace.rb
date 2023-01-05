# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_closing_brace_before) do
  def check
    tokens.select { |token| token.type == :RBRACE }.each do |brace_token|
      prev_token = brace_token.prev_token
      prev_code_token = prev_non_space_token(brace_token)

      next unless prev_token && prev_code_token
      next if %i[LBRACE].include?(prev_token.type)

      next if !%i[LBRACE].include?(prev_code_token.type) && (is_single_space(prev_token) && tokens.index(prev_code_token) == tokens.index(brace_token) - 2)

      next if prev_token.type == :INDENT && (tokens.index(prev_code_token) == tokens.index(brace_token) - 3)

      next if prev_token.type == :NEWLINE && (tokens.index(prev_code_token) == tokens.index(brace_token) - 2)

      notify(
        :error,
        message: 'there should be a single space or newline before a closing brace',
        line: prev_code_token.next_token.line,
        column: prev_code_token.next_token.column,
        token: prev_code_token.next_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]

    next_token = token

    until next_token.type == :RBRACE
      break if tokens[tokens.index(next_token)..-1].first(2).collect(&:type) == %i[NEWLINE RBRACE]

      break if tokens[tokens.index(next_token)..-1].first(3).collect(&:type) == %i[NEWLINE INDENT RBRACE]

      remove_token(next_token)
      next_token = next_token.next_token
    end

    add_token(tokens.index(next_token), new_single_space) if next_token.type == :RBRACE && !%i[LBRACE NEWLINE INDENT].include?(next_token.prev_token.type)
  end
end

PuppetLint.new_check(:manifest_whitespace_closing_brace_after) do
  def check
    tokens.select { |token| token.type == :RBRACE }.each do |brace_token|
      next_token = brace_token.next_token

      next unless next_token
      next if after_bracket_tokens.include?(next_token.type)

      if next_token.type == :WHITESPACE
        next_code_token = next_non_space_token(brace_token)
        next unless next_code_token
        next unless after_bracket_tokens.include?(next_code_token.type)
      end

      notify(
        :error,
        message: 'there should be either a bracket, punctuation mark, closing quote or a newline after a closing brace, or whitespace and none of the aforementioned',
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

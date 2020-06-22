# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_opening_bracket_before) do
  def check
    tokens.select { |token| %i[LBRACE LPAREN LBRACK].include?(token.type) }.each do |brace_token|
      prev_token = brace_token.prev_token
      prev_code_token = brace_token.prev_code_token

      next unless prev_token && prev_code_token
      if %i[LPAREN LBRACK LBRACE COMMA SEMIC].include?(prev_code_token.type)
        next
      end
      if brace_token.type != :LBRACE && !%i[WHITESPACE NEWLINE INDENT].include?(prev_token.type)
        next
      end
      next unless tokens.index(prev_code_token) != tokens.index(brace_token) - 2 ||
                  !is_single_space(prev_token)

      notify(
        :error,
        message: 'there should be a single space before an opening bracket',
        line: brace_token.line,
        column: brace_token.column,
        token: brace_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    prev_token = token.prev_token
    prev_code_token = token.prev_code_token

    while prev_code_token != prev_token
      unless %i[WHITESPACE INDENT NEWLINE].include?(prev_token.type)
        raise PuppetLint::NoFix
      end

      remove_token(prev_token)
      prev_token = prev_token.prev_token
    end

    add_token(tokens.index(token), new_single_space)
  end
end

PuppetLint.new_check(:manifest_whitespace_opening_bracket_after) do
  def check
    tokens.select { |token| %i[LBRACE LPAREN LBRACK].include?(token.type) }.each do |brace_token|
      next_token = brace_token.next_token

      next unless next_token && !is_single_space(next_token)
      next if %i[LPAREN LBRACK LBRACE RBRACE].include?(next_token.type)
      if brace_token.type != :LBRACE && !%i[WHITESPACE NEWLINE INDENT].include?(next_token.type)
        next
      end

      if next_token.type == :NEWLINE
        next_token = next_token.next_token
        next if next_token.type != :NEWLINE
      end

      notify(
        :error,
        message: 'there should be a single space or single newline after an opening bracket',
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

    if token.type == :NEWLINE
      while token && token.type == :NEWLINE
        remove_token(token)
        token = token.next_token
      end
      return
    end

    add_token(tokens.index(token), new_single_space)
  end
end

# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_opening_brace_before) do
  def check
    tokens.select { |token| token.type == :LBRACE }.each do |brace_token|
      prev_token = brace_token.prev_token
      prev_code_token = prev_non_space_token(brace_token)

      next unless prev_token && prev_code_token

      next if %i[COMMA].include?(prev_code_token.type) && %i[INDENT NEWLINE].include?(prev_token.type)
      next if %i[COMMENT COLON].include?(prev_code_token.type)

      if %i[LPAREN LBRACK LBRACE].include?(prev_code_token.type)
        next if tokens.index(prev_code_token) == tokens.index(brace_token) - 1
        next if tokens[tokens.index(prev_code_token)..tokens.index(brace_token)].collect(&:type).include?(:NEWLINE)
      else
        next unless tokens.index(prev_code_token) != tokens.index(brace_token) - 2 ||
                    !is_single_space(prev_token)
      end

      notify(
        :error,
        message: 'there should be a single space before an opening brace',
        line: brace_token.line,
        column: brace_token.column,
        token: brace_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    prev_token = token.prev_token
    prev_code_token = prev_non_space_token(token)

    while prev_code_token != prev_token
      raise PuppetLint::NoFix unless %i[WHITESPACE INDENT NEWLINE].include?(prev_token.type)

      remove_token(prev_token)
      prev_token = prev_token.prev_token
    end

    add_token(tokens.index(token), new_single_space) unless %i[LPAREN LBRACK LBRACE].include?(prev_code_token.type)
  end
end

PuppetLint.new_check(:manifest_whitespace_opening_brace_after) do
  def check
    tokens.select { |token| token.type == :LBRACE }.each do |brace_token|
      next_token = brace_token.next_token

      next unless next_token && !is_single_space(next_token)
      next if %i[RBRACE LBRACK LBRACE].include?(next_token.type)

      if next_token.type == :NEWLINE
        next_token = next_token.next_token
        next if next_token.type != :NEWLINE
      end

      notify(
        :error,
        message: 'there should be a single space or single newline after an opening brace',
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

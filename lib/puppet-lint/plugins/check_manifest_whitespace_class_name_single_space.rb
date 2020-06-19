# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_class_name_single_space_before) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      class_token = class_idx[:tokens].first
      name_token = class_token.next_token_of(:NAME)
      next unless name_token

      next_token = class_token.next_token
      next unless tokens.index(name_token) != tokens.index(class_token) + 2 ||
                  next_token.value != ' '

      notify(
        :error,
        message: 'there should be a single space between the class or defined resource statement and the name',
        line: next_token.line,
        column: next_token.column,
        token: next_token,
      )
    end
  end

  def fix(problem)
    raise PuppetLint::NoFix if problem[:token].type != :WHITESPACE

    problem[:token].value = ' '
  end
end

PuppetLint.new_check(:manifest_whitespace_class_name_single_space_after) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      class_token = class_idx[:tokens].first
      name_token = class_token.next_token_of(:NAME)
      next unless name_token

      next_token = name_token.next_token
      bracket_token = name_token.next_token_of(%i[LPAREN LBRACE])
      next unless tokens.index(name_token) != tokens.index(bracket_token) - 2 ||
                  next_token.value != ' '

      notify(
        :error,
        message: 'there should be a single space between the class or resource name and the first bracket',
        line: next_token.line,
        column: next_token.column,
        token: next_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    bracket_token = token.prev_token.next_token_of(%i[LPAREN LBRACE])

    if token == bracket_token
      add_token(tokens.index(bracket_token), PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0))
      return
    end

    while token != bracket_token
      unless %i[WHITESPACE INDENT NEWLINE].include?(token.type)
        raise PuppetLint::NoFix
      end

      remove_token(token)
      token = token.next_token
    end

    add_token(tokens.index(bracket_token), PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0))
  end
end

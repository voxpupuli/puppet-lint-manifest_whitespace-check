# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_class_opening_curly_brace) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      class_token = class_idx[:tokens].first
      bracket_token = class_token.next_token_of(:LBRACE)
      prev_token = bracket_token.prev_token
      prev_code_token = bracket_token.prev_token_of(%i[RPAREN NAME])

      next unless prev_code_token
      next unless tokens.index(prev_code_token) != tokens.index(bracket_token) - 2 ||
                  !is_single_space(prev_token)

      notify(
        :error,
        message: 'there should be a single space before the opening curly bracket of a class body',
        line: bracket_token.line,
        column: bracket_token.column,
        token: bracket_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    prev_code_token = token.prev_token_of(%i[RPAREN NAME]).next_token

    while token != prev_code_token
      unless %i[WHITESPACE INDENT NEWLINE].include?(prev_code_token.type)
        raise PuppetLint::NoFix
      end

      remove_token(prev_code_token)
      prev_code_token = prev_code_token.next_token
    end

    add_token(tokens.index(token), new_single_space)
  end
end

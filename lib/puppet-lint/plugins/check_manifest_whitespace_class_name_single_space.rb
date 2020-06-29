# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_class_name_single_space_before) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      class_token = class_idx[:tokens].first
      name_token = class_token.next_token_of(%i[NAME FUNCTION_NAME])
      next unless name_token

      next_token = class_token.next_token
      next unless tokens.index(name_token) != tokens.index(class_token) + 2 ||
                  !is_single_space(next_token)

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
      name_token = class_token.next_token_of(%i[NAME FUNCTION_NAME])
      next unless name_token

      next_token = name_token.next_token
      next_code_token = next_non_space_token(name_token)
      next unless tokens.index(name_token) != tokens.index(next_code_token) - 2 ||
                  !is_single_space(next_token)

      notify(
        :error,
        message: 'there should be a single space between the class or resource name and the next item',
        line: name_token.line,
        column: name_token.column,
        token: name_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]

    next_token = token.next_token
    next_code_token = next_non_space_token(token)

    while next_token != next_code_token
      remove_token(next_token)
      next_token = next_token.next_token
    end

    add_token(tokens.index(next_code_token), new_single_space)
  end
end

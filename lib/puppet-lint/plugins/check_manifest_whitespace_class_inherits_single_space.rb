# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_inherits_name_single_space_before) do
  def check
    tokens.select { |token| token.type == :INHERITS }.each do |inherits_token|
      name_token = inherits_token.next_token_of(%i[NAME FUNCTION_NAME])
      next unless name_token

      next_token = inherits_token.next_token
      next unless tokens.index(name_token) != tokens.index(inherits_token) + 2 ||
                  !is_single_space(next_token)

      notify(
        :error,
        message: 'there should be a single space between the inherits statement and the name',
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

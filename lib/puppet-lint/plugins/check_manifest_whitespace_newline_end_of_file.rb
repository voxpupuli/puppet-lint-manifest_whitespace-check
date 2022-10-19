# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_missing_newline_end_of_file) do
  def check
    last_token = tokens.last

    if last_token && last_token.type != :NEWLINE
      notify(
        :error,
        message: 'there should be a single newline at the end of a manifest',
        line: last_token.line,
        column: last_token.column,
        token: last_token,
      )
    end
  end

  def fix(problem)
    index = tokens.index(problem[:token])
    tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))
  end
end

PuppetLint.new_check(:manifest_whitespace_double_newline_end_of_file) do
  def check
    last_token = tokens.last

    if last_token && last_token.type == :NEWLINE
      while last_token.prev_token && last_token.prev_token.type == :NEWLINE
        notify(
          :error,
          message: 'there should be a single newline at the end of a manifest',
          line: last_token.line,
          column: last_token.column,
          token: last_token,
        )

        last_token = last_token.prev_token
      end
    end
  end

  def fix(problem)
    tokens.delete(problem[:token])
  end
end

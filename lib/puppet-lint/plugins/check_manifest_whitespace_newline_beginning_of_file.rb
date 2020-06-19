# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_newline_beginning_of_file) do
  def check
    tokens.each do |token|
      return if token.type != :NEWLINE

      notify(
        :error,
        message: 'there should not be a newline at the beginning of a manifest',
        line: token.line,
        column: token.column,
        token: token,
      )
    end
  end

  def fix(problem)
    remove_token(problem[:token])
  end
end

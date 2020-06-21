# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_two_empty_lines) do
  def check
    tokens.select { |token| token.type == :NEWLINE }.each do |token|
      prev_newline = token.prev_token_of(:NEWLINE)
      next unless prev_newline

      prev_newline = prev_newline.prev_token_of(:NEWLINE)
      next unless prev_newline

      good_to_go = true
      tokens.index(prev_newline).upto(tokens.index(token)).each do |between_token_idx|
        unless %i[NEWLINE WHITESPACE INDENT].include?(tokens[between_token_idx].type)
          good_to_go = false
          break
        end
      end
      next unless good_to_go

      notify(
        :error,
        message: 'there should be no two consecutive empty lines',
        line: token.line,
        column: token.column,
        token: token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    remove_token(token)
  end
end

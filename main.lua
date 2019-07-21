local lexer = require 'lexer'

lexer.parseFile(arg[1])

while(lexer.hasNextToken()) do
  local token = lexer.getNextToken()
  print(token.value, token.type)
end

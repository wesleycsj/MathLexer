-- Author: Wesley, Duclier and Luis
-- Lexical analyser of math language
local lexer = {}
-- File to be opened
local file = nil
local reservedWords = {'print', 'pow', 'sqrt'}
local currentLine = nil
local currentFileLine = 0
local currentFileColumn = 0
local currentState = 'idle'

function lexer.parseFile(fileName)
  --file = io.open(arg[1], "r")
  file = io.open(fileName, "r")
  parse()
  io.close()
end

function getNextLine()
  local buffer = file:read()

  -- Test if exists a net line
  if buffer then
    currentFileLine = currentFileLine + 1
    currentFileColumn = 0
    return buffer .. ''
  end

  return nil
end

function getPreviousChar()
  if ((currentFileColumn - 1) >= 1) then
    currentFileColumn = currentFileColumn - 1
    return currentLine:sub(currentFileColumn, currentFileColumn)
  else
    return nil
  end
end

function getNextChar()
  if ((currentFileColumn + 1) <= string.len(currentLine)) then
    currentFileColumn = currentFileColumn + 1
    return currentLine:sub(currentFileColumn, currentFileColumn)
  else
    return nil
  end
end

function getLookAHead()
  local nextFileColumn =  currentFileColumn + 1
  if (nextFileColumn <= string.len(currentLine)) then
    return currentLine:sub(nextFileColumn, nextFileColumn)
  else
    return nil
  end
end
function isReservedWord(token)
  local index = {}
  for k,v in pairs(reservedWords) do
     index[v] = k
  end
  return index[token]
end

function isNumber(token)
  local numbers = {'0','1','2','3','4','5','6','7','8','9'}
  local index = {}
  for k,v in pairs(numbers) do
     index[v] = k
  end
  return index[token]
end

function isOperator(token)
  local operators = {'=','+','-','*','/','%','(',')'}
  local index = {}
  for k,v in pairs(operators) do
     index[v] = k
  end
  return index[token]
end

function isAlpha(token)
  local characters = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
  local index = {}
  for k,v in pairs(characters) do
     index[v] = k
  end
  return index[token]
end
-- FSM
local states = {'identifier','keyword', 'integer', 'real', 'operator'}
local tokens = {}
local currentToken = 0

function lexer.putToken(tokenType, token, row, column)
  table.insert(tokens, {
    type  = tokenType,
    value = token,
    row    = row,
    column = column
  })
end

function lexer.hasNextToken()
  if currentToken < #tokens then
    return true
  end

  return false
end

function lexer.getNextToken()
  currentToken = currentToken + 1
  return tokens[currentToken]
end

function parse()
  --openFile()
  currentLine = getNextLine()
  local charBuffer = ''
  while(currentLine) do
    currentChar = getNextChar()
    charBuffer = ''
    while currentChar do
      local lookahead = getLookAHead()
      --ignore whitespaces
      while currentChar == ' ' do
        currentChar = getNextChar()
      end

      charBuffer = charBuffer .. currentChar

      if (isReservedWord(charBuffer) and (lookahead == ' ' or lookahead == nil)) then
        --print('keyword', reservedWords[isReservedWord(charBuffer)] , currentFileLine, ':', (currentFileColumn - string.len(charBuffer) + 1))
        lexer.putToken('keyword', reservedWords[isReservedWord(charBuffer)], currentFileLine, (currentFileColumn - string.len(charBuffer) + 1))
        -- Ignores the whitespace at next position
        getNextChar()
        charBuffer = ''
      elseif(isNumber(charBuffer)) then
        while (isNumber(getLookAHead())) do
          currentChar = getNextChar()
          charBuffer = charBuffer .. currentChar
        end
        --print('number', charBuffer , currentFileLine, ':', (currentFileColumn - string.len(charBuffer) + 1))
        lexer.putToken('number', charBuffer, currentFileLine, (currentFileColumn - string.len(charBuffer) + 1))
        charBuffer = ''
      elseif(isOperator(charBuffer)) then
        --print('operator', charBuffer , currentFileLine, ':', (currentFileColumn - string.len(charBuffer) + 1))
        lexer.putToken('operator', charBuffer, currentFileLine, (currentFileColumn - string.len(charBuffer) + 1))
        charBuffer = ''
      elseif(isAlpha(currentChar) and not isReservedWord(charBuffer) and (lookahead == ' ' or lookahead == nil)) then
        --print('identifier', charBuffer , currentFileLine, ':', (currentFileColumn - string.len(charBuffer) + 1))
        lexer.putToken('identifier', charBuffer, currentFileLine, (currentFileColumn - string.len(charBuffer) + 1))
        getNextChar()
        charBuffer = ''
      end
      currentChar = getNextChar()
    end
    currentLine = getNextLine()
  end
end

-- function main()
--   parse()
--   while (hasNextToken()) do
--     local token = lexer.getNextToken()
--     print(token.value, token.type)
--   end
-- end
-- Runs program and close buffer at program be runned
--main()
--io.close()

return lexer

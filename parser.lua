-- Author: Wesley, Duclier and Luis
-- parser of math language
local parser = {}
local lexer = require 'lexer'
local Tree = require 'tree'
local lineCount = 0
lexer.parseFile(arg[1])

-- Both stacks, stack stores productions, and input the input string to be parsed
local stack = {}
local input = {}
-- Theres a map behind
local symbols = {}
symbols['id']      = '@'
symbols['keyword'] = '%'
symbols['number']  = '#'
symbols['empty']   = '&'

local tablePrediction = {
  -- @ = id
  -- % = keyword
  -- # = number
  -- & = empty
  {'V=E', nil, nil,  nil,  nil,   nil,   nil,  '%(E)', nil,    nil}, -- S
  {'TY',  nil, 'TY', nil,  nil,   nil,   nil,   nil, 'TY',     nil}, -- E
  { nil,  '&',  nil, '+TY', '-TY',nil,   nil,   nil, nil,      '&'}, -- E' mapped to Y
  {'FZ',  nil, 'FZ', nil,  nil,   nil,   nil,   nil, 'FZ',     nil}, -- T
  { nil,  '&',  nil,  '&',   '&', '/FZ', '*FZ', nil, nil,      '&'}, -- T' mapped to Z
  {'V',   nil, '(E)',nil,  nil,   nil,   nil,   nil, 'N',      nil}, -- F
  {'@',  nil, nil,  nil,  nil,    nil,   nil,   nil, nil,      nil}, -- V
  { nil,  nil, nil,  nil,  nil,   nil,   nil,   nil, '#',      nil} --  N
}

local Terminals = {}
Terminals['@'] = 1
Terminals[')'] = 2
Terminals['('] = 3
Terminals['+'] = 4
Terminals['-'] = 5
Terminals['/'] = 6
Terminals['*'] = 7
Terminals['%'] = 8
Terminals['#'] = 9
Terminals['$'] = 10
Terminals['='] = 11

local nonTerminals = {}
nonTerminals['S'] = 1
nonTerminals['E'] = 2
nonTerminals['Y'] = 3
nonTerminals['T'] = 4
nonTerminals['Z'] = 5
nonTerminals['F'] = 6
nonTerminals['V'] = 7
nonTerminals['N'] = 8

-- Stack implementation
function initStack()
  -- Push '$' symbol
  pushStack('$')
  -- Push root symbol
  pushStack('S')
  -- Push '$' symbol to input
  pushInput('$')
end

function clearStack()
  if #stack > 0 then
    for k in pairs (stack) do
      stack[k] = nil
    end
  end
  if #input > 0 then
    for k in pairs (input) do
      input[k] = nil
    end
  end
end

function pushStack(element)
  if #element > 1 then
    local inputString = string.reverse(element)
    for i=1,#inputString do
      table.insert(stack, string.sub(inputString, i ,i))
    end
  elseif table.insert(stack, element) then
      return true
  end
  return false
end

function popStack()
  if #stack > 0 then
    table.remove(stack, #stack)
    return true
  end

  return false
end


function pushInput(element)
  if type(element) == 'table' then
    local inputString = (element.value)
      table.insert(input, {
        -- value = string.sub(inputString, i ,i),
        value = inputString,
        type  = element.type
      })
      return true
  elseif table.insert(input, element) then
      return true
  end
  return false
end

function popInput()
  if #stack > 0 then
    table.remove(input, 1)
    return false
  end

  return false
end

function getStackTop()
  return stack[#stack]
end

function getInputTop()
  return input[1]
end
-- Print both Stack and Input elements
function printStack()
  local stackBuffer = ''
  local inputBuffer = ''
  for k,v in pairs(stack) do
    stackBuffer = stackBuffer .. v
  end
  for k,v in pairs(input) do
    if v ~= '$' then
      inputBuffer = inputBuffer .. v.value
    else
      inputBuffer = inputBuffer .. '$'
    end
  end
  print('Stack:' .. stackBuffer .. " Input:" .. inputBuffer)
end

-- Parse
function parse()
  local stackTopElement = getStackTop()
  local inputTopElement = getInputTop()
  local inputTopElementNonMapped = getInputTop().value

  -- Just a quick fix to get the correct value from Terminals list
  if inputTopElement == '$' then
    inputTopElement = '$'
  elseif inputTopElement.type == 'id' or inputTopElement.type == 'keyword' or inputTopElement.type == 'number' then
    inputTopElement = symbols[inputTopElement.type]
  else
    inputTopElement = inputTopElement.value
  end
  -- Tests if accepts or not
  if #stack <= 1 and #input > 1 then
    return false
  elseif (Terminals[stackTopElement] ~= nil and Terminals[inputTopElement] ~= nil) and (stackTopElement ~= inputTopElement) then
    print('ERROR: Expected a `' .. stackTopElement .. '` instead a `' .. inputTopElement .. '` at line ' .. lineCount)
    return false
  elseif stackTopElement == '$' and inputTopElement == '$' then
    return true
  end

  if #stack > 1 then
    if stackTopElement == symbols['empty'] then
      popStack()
    elseif nonTerminals[stackTopElement] then
      local terminalPos    = Terminals[inputTopElement]
      local nonTerminalPos = nonTerminals[stackTopElement]
      local production     = tablePrediction[nonTerminalPos][terminalPos]
      if production then
        popStack()
        if production == symbols['empty'] then
          local lastUnvisited = Tree.getUnvisited(Tree.getRoot())
          Tree.match(lastUnvisited, symbols['empty'])
        else
          local lastUnvisited = Tree.getUnvisited(Tree.getRoot())
          Tree.derive(lastUnvisited, production)
          pushStack(production)
        end
      else
        return false
      end
    elseif stackTopElement == inputTopElement then
      local lastUnvisited = Tree.getUnvisited(Tree.getRoot())
      Tree.match(lastUnvisited, inputTopElementNonMapped)
      popStack()
      popInput()
    end
    return parse()
  end
end

local isAccepting = true
while(isAccepting and lexer.hasNextToken()) do
  lineCount = lineCount + 1
  local token = lexer.getNextToken()
  -- Push all elements until a delimiter ;
  clearStack()
  while (token.type ~= 'delimiter') do
    pushInput(token)
    token = lexer.getNextToken()
  end
  initStack()

  Tree.initTree('S')
  isAccepting = parse()
  Tree.postOrder(Tree.getRoot())
  if isAccepting then
    print('Linha ' .. lineCount .. ' aceita.')
  else
    print('Linha ' .. lineCount .. ' rejeita.')
  end
end

--lexer.printTokens()

local Tree = {}

local index = 0

function Tree.initTree(rootValue)
  if #Tree < 1 then
    table.insert(Tree, {
      index = index,
      value = rootValue,
      visited = false,
      children = {}
    })
    index = index + 1
    return true
  else
    print('Could not initialized Tree. Length greater than zero.')
    return false
  end
end

function Tree.getRoot()
  if #Tree > 0 then
    return Tree[1]
  else
    print('Tree not initialized.')
    return nil
  end
end

function Tree.putNode(node, value)
  if node then
    table.insert(node.children, {
      index = index,
      value = value,
      visited = false,
      children = {}
    })
    index = index + 1
    return true
  else
    print('Could not insert at root element.' .. value)
    assert()
    return false
  end
end

function Tree.getUnvisited(node)
  local left = node.children[1]
  local center = node.children[2]
  local right = node.children[3]
  if not node.visited then
    return node
  end

  local nodeunvisited = nil
  if right and Tree.getUnvisited(right) then
    nodeunvisited = Tree.getUnvisited(right)
  end
  if center and Tree.getUnvisited(center) then
    nodeunvisited = Tree.getUnvisited(center)
  end
  if left and Tree.getUnvisited(left) then
    nodeunvisited = Tree.getUnvisited(left)
  end
  return nodeunvisited
end

function Tree.postOrder(node)
  local left = node.children[1]
  local center = node.children[2]
  local right = node.children[3]
  if left then
    Tree.postOrder(left)
  end
  if center then
    Tree.postOrder(center)
  end
  if right then
    Tree.postOrder(right)
  end
  print(node.value)
end

function Tree.derive(node, production)
  local lastUnvisited = Tree.getUnvisited(Tree.getRoot())
  for i = 1, #production do
    Tree.putNode(node, string.sub(production, i,i))
  end
  node.visited = true
end

function Tree.match(node, input)
  if node.value ~= input then
    Tree.derive(node, input)
  end
  local newUnvisited = Tree.getUnvisited(Tree.getRoot())
  if newUnvisited.value == input then
    newUnvisited.visited = true
  end
end

-- Tree.initTree('S')
-- Tree.derive(Tree.getUnvisited(Tree.getRoot()),'V=E')
-- Tree.derive(Tree.getUnvisited(Tree.getRoot()),'@')
-- Tree.match(Tree.getUnvisited(Tree.getRoot()), 'x')
-- Tree.match(Tree.getUnvisited(Tree.getRoot()), '=')
-- Tree.derive(Tree.getUnvisited(Tree.getRoot()),'TF')
-- Tree.derive(Tree.getUnvisited(Tree.getRoot()),'Z')
-- Tree.derive(Tree.getUnvisited(Tree.getRoot()),'#')
-- Tree.match(Tree.getUnvisited(Tree.getRoot()), '3')
-- Tree.match(Tree.getUnvisited(Tree.getRoot()), '&')
-- Tree.postOrder(Tree.getRoot())

return Tree

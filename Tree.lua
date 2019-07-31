local Tree = {}

local index = 0

function Tree.initTree(rootValue)
  index = index + 1
  if #Tree < 1 then
    table.insert(Tree, {
      index = index,
      value = rootValue,
      visited = true,
      children = {}
    })
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

function Tree.putNode(root, value)
  index = index + 1
  if root then
    table.insert(root.children, {
      index = index,
      value = value,
      visited = false,
      children = {}
    })
    return true
  else
    print('Could not insert at root element.')
    return false
  end
end

-- Returns the most recently visited node
local lastVisitedNode = nil
function Tree.getLastVisited(root)
  if root then
    local leftNode = root.children[1]
    local centerNode = root.children[2]
    local rightNode = root.children[3]
    if root.visited then
--    print(root.value)
      lastVisitedNode = root
    end
    Tree.getLastVisited(leftNode)
    Tree.getLastVisited(centerNode)
    Tree.getLastVisited(rightNode)
  end
end

-- Returns the most recently unvisited node
local lastUnvisitedNode = nil
function Tree.getLastUnvisited(root)
  if root then
    local leftNode = root.children[1]
    local centerNode = root.children[2]
    local rightNode = root.children[3]
    if root.visited then
--    print(root.value)
      Tree.getLastUnvisited(rightNode)
      Tree.getLastUnvisited(centerNode)
      Tree.getLastUnvisited(leftNode)
    else
      lastUnvisitedNode = root
    end
  end
end

function Tree.getLastVisitedNode()
  return lastVisitedNode
end

function Tree.getLastUnvisitedNode()
  return lastUnvisitedNode
end

function Tree.isOnlyRoot()
  return #Tree[1].children == 0
end

--Print the tree
function Tree.print(root)
  if root then
    local leftNode = root.children[1]
    local centerNode = root.children[2]
    local rightNode = root.children[3]
    print('Root ' .. root.value)
    Tree.print(leftNode)
    Tree.print(centerNode)
    Tree.print(rightNode)
  end
end

function Tree.printLevel(root)
  if root then
    local leftNode = root.children[1]
    local centerNode = root.children[2]
    local rightNode = root.children[3]
    print('Root ' .. root.value)
    if leftNode then
      print(leftNode.value)
    end
    if centerNode then
      print(centerNode.value)
    end
    if rightNode then
      print(rightNode.value)
    end
  end
end

function Tree.derive(production)
  if Tree.isOnlyRoot() then
    for i=1, #production do
      print(production)
      Tree.putNode(Tree.getRoot(), string.sub(production,i,i))
    end
  else
    Tree.getLastUnvisited(Tree.getRoot())
    local lastunvisited = Tree.getLastUnvisitedNode()
    for i=1, #production do
      Tree.putNode(lastunvisited, string.sub(production,i,i))
    end
  end
end

Tree.initTree('root')
local root = Tree.getRoot()

Tree.putNode(root, 'V')
Tree[1].children[1].visited = true
Tree.putNode(Tree[1].children[1], '@')
Tree[1].children[1].children[1].visited = true
Tree.putNode(Tree[1].children[1].children[1], 'x')
Tree[1].children[1].children[1].children[1].visited = true
--Tree[1].children[1].children[1].visited = true
--Tree[1].children[1].children[1].children[1].visited = true
Tree.putNode(root, '=')
Tree[1].children[2].visited = true
Tree.putNode(root, 'E')
Tree[1].children[3].visited = true
Tree.putNode(Tree[1].children[3], '+')
Tree[1].children[3].children[1].visited = false

Tree.getLastVisited(root)
local x = Tree.getLastVisitedNode()
--print(x.value)
--Tree.print(Tree.getRoot())
return Tree

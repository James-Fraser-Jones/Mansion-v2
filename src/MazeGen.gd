extends Node

############################# Top level ###############################

#produce 2D array of booleans indicating wall status of each cell in a 2D grid representing maze
#based on connectivity of nodes in the given ust (each node represents a square area of corridor)
#cellSize and wallWidth are given in number of grid cells
#true indicates wall, false indicates corridor
func gen_maze(numRows: int, numCols: int, corridorWidth: int, wallWidth: int, seedNum: int, braid: bool, unbiased: bool, entrances: bool) -> Array:
	seed(seedNum)
	var st = wilson(numRows, numCols) if unbiased else growing_tree(numRows, numCols)
	if braid: braid(st)
	var maze = st_to_maze(corridorWidth, wallWidth, st)
	if entrances: add_entrances(maze, corridorWidth, wallWidth)
	return maze

############################# Rendering ###############################

func st_to_maze(corridorWidth: int, wallWidth: int, ust: Dictionary) -> Array:
	var gridWidth = ust.numCols * corridorWidth + ust.numCols * wallWidth + wallWidth
	var gridHeight = ust.numRows * corridorWidth + ust.numRows * wallWidth + wallWidth
	var maze = []
	for rowNum in range(gridHeight):
		var row = []
		for colNum in range(gridWidth):
			var isWall = false
			#check outer border
			if rowNum < wallWidth or rowNum >= gridHeight - wallWidth \
			or colNum < wallWidth or colNum >= gridWidth - wallWidth: 
				isWall = true
			#check position relative to local box
			else:
				var boxWithBorderSize = corridorWidth + wallWidth
				var position = 0
				if rowNum % boxWithBorderSize < wallWidth: position += 1
				if colNum % boxWithBorderSize < wallWidth: position += 2
				if position == 1 or position == 2:
					var currentNode = {"rowIndex": rowNum / boxWithBorderSize, "colIndex": colNum / boxWithBorderSize}
					var searchNode
					match position:
						1: searchNode = {"rowIndex": (rowNum / boxWithBorderSize) - 1, "colIndex": colNum / boxWithBorderSize}
						2: searchNode = {"rowIndex": rowNum / boxWithBorderSize, "colIndex": (colNum / boxWithBorderSize) - 1}
					isWall = !found_node_connection(currentNode, searchNode, ust.edges)
				else:
					isWall = position == 3
			row.append(isWall)
		maze.append(row)
	return maze

############################# Braiding ###############################

#braids an existing st, removing all dead ends (4-cycles)
func braid(st: Dictionary) -> void:
	for rowNum in range(st.numRows):
		for colNum in range(st.numCols):
			var currentNode = {"rowIndex": rowNum, "colIndex": colNum}
			var neighbours = []
			for edge in st.edges:
				if node_eq(currentNode, edge.source):
					neighbours.append(edge.target)
				elif node_eq(currentNode, edge.target):
					neighbours.append(edge.source)
				if neighbours.size() > 1:
					break
			if neighbours.size() == 1:
				var newNeighbours = get_neighbours(st.numRows, st.numCols, currentNode)
				erase_node(newNeighbours, neighbours[0])
				st.edges.append({"source": currentNode, "target": newNeighbours[randi() % newNeighbours.size()]})

############################# Wilson's Algorithm ###############################

#produces a uniform spanning tree using wilson's algorithm
#output consists of an array of "edges" given by dictionaries storing source and target nodes
func wilson(numRows: int, numCols: int) -> Dictionary:
	var edges = []
	var unvisitedNodes = generate_grid(numRows, numCols)
	var visitedNodes = [unvisitedNodes.pop_front()]
	while unvisitedNodes.size() > 0:
		#Choose a random initial node and add to the walk
		var currentNode = unvisitedNodes[randi() % unvisitedNodes.size()]
		var walk = [currentNode]
		while search_node(visitedNodes, walk[walk.size()-1]) == -1:
			
			#Get array of possible neighbours
			var neighbours = get_neighbours(numRows, numCols, currentNode)
			
			#Choose a new node to add to the walk from possible neighbours
			var newNode = neighbours[randi() % neighbours.size()]
			
			#If the newly chosen node would form a cycle in the walk, remove from walk all most recent 
			#nodes back to previous instance of that node, which remains in the array, else add newly chosen node to walk
			var foundIndex = search_node(walk, newNode)
			if foundIndex > -1:
				for i in range((walk.size()-1) - foundIndex):
					walk.pop_back()
				currentNode = walk[walk.size()-1]
			else:
				walk.append(newNode)
				currentNode = newNode
			
		#Add edges based on walk, 
		#take nodes out of unvisited and add to visited for all but last node in walk (which is already in visited)
		for i in range(walk.size()-1):
			edges.append({"source": walk[i], "target": walk[i+1]})
			visitedNodes.append(walk[i])
			erase_node(unvisitedNodes, walk[i])
	return {"numRows": numRows, "numCols": numCols, "edges": edges}

############################# Growing Tree Algorithm ###############################

#produce a spanning tree using the growing tree algorithm
func growing_tree(numRows: int, numCols: int) -> Dictionary:
	var edges = []
	var unvisitedNodes = generate_grid(numRows, numCols)
	var initialIndex = randi() % unvisitedNodes.size()
	
	#1. Let visitedNodes be a list of cells, initially empty. Add one cell to C, at random.
	var visitedNodes = [unvisitedNodes[initialIndex]]
	unvisitedNodes.remove(initialIndex)
	
	#3. Repeat #2 until visitedNodes is empty.
	while visitedNodes.size() > 0:
		#2. Choose a cell from visitedNodes
		var currentNode = choice_function(visitedNodes)
		#get unvisited neighbours
		var unvisitedNeighbours = []
		for neighbour in get_neighbours(numRows, numCols, currentNode):
			if search_node(unvisitedNodes, neighbour) > -1:
				unvisitedNeighbours.append(neighbour)
		
		#2.If there are no unvisited neighbors, remove the cell from visitedNodes
		if unvisitedNeighbours.size() == 0:
			erase_node(visitedNodes, currentNode)
		#2.carve a passage to any unvisited neighbor of that cell, adding that neighbor to visitedNodes as well	
		else:
			var newNode = unvisitedNeighbours[randi() % unvisitedNeighbours.size()]
			visitedNodes.append(newNode)
			edges.append({"source":currentNode,"target":newNode})
			erase_node(unvisitedNodes, newNode)
	return {"numRows": numRows, "numCols": numCols, "edges": edges}
		
func choice_function(visitedNodes: Array) -> Dictionary:
	var choice = visitedNodes[visitedNodes.size()-1] #behave like recursive backtracking algorithm
	#var choice = visitedNodes[randi() % visitedNodes.size()] #behave like prim's algorithm
	#var choice = visitedNodes[0] #behave weird
	return choice

############################# Helpers ###############################

#generates a 2D grid consisting of an array of its nodes with 2D co-ordinates
func generate_grid(numRows: int, numCols: int) -> Array:
	var nodes = []
	for row in range(numRows):
		for col in range(numCols):
			nodes.append({"rowIndex": row, "colIndex": col})
	return nodes

#adds entrances in top left and bottom right corners	
func add_entrances(maze: Array, corridorWidth: int, wallWidth: int) -> void:
	for rowNum in range(wallWidth, wallWidth + corridorWidth):
			for colNum in range(wallWidth):
				maze[rowNum][colNum] = false
	for rowNum in range(maze.size() - wallWidth - corridorWidth, maze.size() - wallWidth):
		for colNum in range(maze[0].size() - wallWidth, maze[0].size()):
			maze[rowNum][colNum] = false
	
#searches a list of (undirected) edges, returns true if the nodes are connected by an edge
func found_node_connection(firstNode: Dictionary, secondNode: Dictionary, edges: Array) -> bool:
	for edge in edges:
		if (node_eq(firstNode, edge.source) and node_eq(secondNode, edge.target)) \
		or (node_eq(firstNode, edge.target) and node_eq(secondNode, edge.source)):
			return true
	return false

#Produce an array of all possible neighbour nodes from a given node, taking edges of grid into account
func get_neighbours(numRows: int, numCols: int, node: Dictionary) -> Array:
	var neighbours = []
	if node.rowIndex > 0: 
		neighbours.append({"rowIndex": node.rowIndex - 1, "colIndex": node.colIndex})
	if node.colIndex > 0: 
		neighbours.append({"rowIndex": node.rowIndex, "colIndex": node.colIndex - 1})
	if node.rowIndex < numRows - 1: 
		neighbours.append({"rowIndex": node.rowIndex + 1, "colIndex": node.colIndex})
	if node.colIndex < numCols - 1: 
		neighbours.append({"rowIndex": node.rowIndex, "colIndex": node.colIndex + 1})
	return neighbours

#erases the first instance of a given node from an array of nodes
func erase_node(array: Array, node: Dictionary) -> void:
	array.remove(search_node(array, node))

#returns index of first instance of given node in an array of nodes, or -1 if not present
func search_node(array: Array, node: Dictionary) -> int:
	for i in range(array.size()):
		var curNode = array[i]
		if node_eq(curNode, node):
			return i
	return -1

#compares two nodes for equality in the expected way
func node_eq(firstNode: Dictionary, secondNode: Dictionary) -> bool:
	return firstNode.rowIndex == secondNode.rowIndex and firstNode.colIndex == secondNode.colIndex

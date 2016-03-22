//
//  Graph.swift
//  GraphAlgorithmVisualizations
//
//  Created by Goote, Nick on 3/21/16.
//  Copyright © 2016 Goote, Nick. All rights reserved.
//

import UIKit

struct NodeLocation : Equatable {
    let row: Int
    let column: Int
}

func ==(lhs: NodeLocation, rhs: NodeLocation) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

enum CellType: String {
    case Wall = "Wall"
    case Empty = "Empty"
    case Start = "Start"
    case End = "End"
}

struct CellState {
    var visitedState : CellVisitedState
    var distance : Double
    var parentNode : NodeLocation?
}

enum CellVisitedState {
    case Unvisited
    case InQueue
    case Processed
}

struct GraphNode {
    /* Graph setup information. */
    var type: CellType
    
    /* Search information. */
    var state: CellState
}

class Graph {
    var nodes : [[GraphNode]] = []
    let numRowsCols: Int
    var Q: [NodeLocation] = []
    var OPEN: [NodeLocation] = []
    
    enum BFSState {
        case Init
        case Loop
        case Done
    }
    var bfsState : BFSState = .Init
    
    enum AStarState {
        case Init
        case Loop
        case Done
    }
    var aStarState : AStarState = .Init
    
    
    init(numRowsCols: Int) {
        self.numRowsCols = numRowsCols
        createInitialNodes(numRowsCols)

        self[0, 0].type = .Start
        self[numRowsCols - 1, numRowsCols - 1].type = .End
    }
    
    func resetCellStates() {
        for row in 0..<numRowsCols {
            for column in 0..<numRowsCols {
                self[row, column].state.distance = Double.infinity
                self[row, column].state.visitedState = .Unvisited
                self[row, column].state.parentNode = nil
            }
        }
        
        Q.removeAll()
        OPEN.removeAll()
        bfsState = .Init
        aStarState = .Init
    }
    
    /********** subscript **********/

    subscript(row: Int) -> [GraphNode] {
        get {
            return nodes[row]
        }
    }
    
    subscript(row: Int, column: Int) -> GraphNode {
        get {
            return nodes[row][column]
        }
        set(newNode) {
            nodes[row][column] = newNode
        }
    }
    
    subscript(nodeLocation: NodeLocation) -> GraphNode {
        get {
            return self[nodeLocation.row, nodeLocation.column]
        }
        set(newNode) {
            self[nodeLocation.row, nodeLocation.column] = newNode
        }
    }
    
    func createInitialNodes(numRowsCols: Int) {
        let defaultState = CellState(visitedState: .Unvisited, distance: Double.infinity, parentNode: nil)
        let defaultNode = GraphNode(type: .Empty, state: defaultState)
        nodes = Array(count: numRowsCols, repeatedValue: Array(count: numRowsCols, repeatedValue: defaultNode))
    }

    func clearExistingCellsOfType(type: CellType) {
        for row in 0..<numRowsCols {
            for column in 0..<numRowsCols {
                if type == self[row, column].type {
                    self[row, column].type = .Empty
                }
            }
        }
    }
    
    func getExistingCellOfType(type: CellType) -> NodeLocation? {
        for row in 0..<numRowsCols {
            for column in 0..<numRowsCols {
                if type == self[row, column].type {
                    return NodeLocation(row: row, column: column)
                }
            }
        }
        return nil
    }
    
    func setStartCell(cell: NodeLocation) {
        clearExistingCellsOfType(.Start)
        self[cell].type = .Start
    }
    
    func getStartCell() -> NodeLocation {
        if let start = getExistingCellOfType(.Start) {
            return start
        }
        return NodeLocation(row: 0, column: 0)
    }
    
    func setEndCell(cell: NodeLocation) {
        clearExistingCellsOfType(.End)
        self[cell].type = .End
    }
    
    func getEndCell() -> NodeLocation {
        if let end = getExistingCellOfType(.End) {
            return end
        }
        return NodeLocation(row: numRowsCols - 1, column: numRowsCols - 1)
    }
    
    func setEmptyCell(cell: NodeLocation) {
        self[cell].type = .Empty
    }
    
    func setWallCell(cell: NodeLocation) {
        self[cell].type = .Wall
    }
    
    func getPossibleCellStates() -> [String] {
        return [CellType.Wall.rawValue, CellType.Empty.rawValue, CellType.Start.rawValue, CellType.End.rawValue]
    }
    
    

    func getSolutionPath() -> [NodeLocation] {
        return getPath(getStartCell(), endNode: getEndCell())
    }

    func getPath(startNode: NodeLocation, endNode: NodeLocation) -> [NodeLocation] {
        var path: [NodeLocation] = []
        
        var currentNode: NodeLocation? = endNode
        while let pathNode = currentNode {
            path.insert(pathNode, atIndex: 0)
            currentNode = self[pathNode].state.parentNode
            
            if pathNode == startNode {
                break
            }
        }
        
        return path
    }
    
    func getPathLength(path: [NodeLocation]) -> Int {
        return path.count - 1
    }
    
    /********** CellState **********/
    
    func nodeDistance(node: NodeLocation) -> Double? {
        return self[node].state.distance
    }
    
    func nodeParent(node: NodeLocation) -> NodeLocation? {
        return self[node].state.parentNode
    }
    
    func nodeVisited(node: NodeLocation) -> Bool {
        return !(CellVisitedState.Unvisited == self[node].state.visitedState)
    }
    
    func nodeInQueue(node: NodeLocation) -> Bool {
        return CellVisitedState.InQueue == self[node].state.visitedState
    }
    
    func nodeProcessed(node: NodeLocation) -> Bool {
        return CellVisitedState.Processed == self[node].state.visitedState
    }
    
    /********** CellType **********/
    
    func cellType(cell: NodeLocation) -> CellType {
        return self[cell].type
    }
    
    
    
    
    
    
    
    
    func isValidNode(node: NodeLocation) -> Bool {
        if node.row >= 0 &&
            node.row < numRowsCols &&
            node.column >= 0 &&
            node.column < numRowsCols &&
            self[node].type != .Wall {
                return true
        }
        return false
    }
    
    func isValidAndUnvisitedNode(node: NodeLocation) -> Bool {
        return isValidNode(node) && !nodeVisited(node)
    }
    
    func getAdjacentValidUnvisitedNeighbor(node: NodeLocation) -> NodeLocation? {
        let upNode: NodeLocation = NodeLocation(row: node.row - 1, column: node.column)
        let upRightNode: NodeLocation = NodeLocation(row: node.row - 1, column: node.column + 1)
        let rightNode: NodeLocation = NodeLocation(row: node.row, column: node.column + 1)
        let downRightNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column + 1)
        let downNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column)
        let downLeftNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column - 1)
        let leftNode: NodeLocation = NodeLocation(row: node.row, column: node.column - 1)
        let upLeftNode: NodeLocation = NodeLocation(row: node.row - 1, column: node.column - 1)
        
        if(isValidAndUnvisitedNode(upNode)) {
            return upNode
        }
        if(isValidAndUnvisitedNode(upRightNode)) {
            return upRightNode
        }
        if(isValidAndUnvisitedNode(rightNode)) {
            return rightNode
        }
        if(isValidAndUnvisitedNode(downRightNode)) {
            return downRightNode
        }
        if(isValidAndUnvisitedNode(downNode)) {
            return downNode
        }
        if(isValidAndUnvisitedNode(downLeftNode)) {
            return downLeftNode
        }
        if(isValidAndUnvisitedNode(leftNode)) {
            return leftNode
        }
        if(isValidAndUnvisitedNode(upLeftNode)) {
            return upLeftNode
        }
        
        return nil
    }
    
    func getAdjacentValidNeighbors(node: NodeLocation) -> [NodeLocation] {
        var neighbors: [NodeLocation] = []
        
        let upNode: NodeLocation = NodeLocation(row: node.row - 1, column: node.column)
        let upRightNode: NodeLocation = NodeLocation(row: node.row - 1, column: node.column + 1)
        let rightNode: NodeLocation = NodeLocation(row: node.row, column: node.column + 1)
        let downRightNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column + 1)
        let downNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column)
        let downLeftNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column - 1)
        let leftNode: NodeLocation = NodeLocation(row: node.row, column: node.column - 1)
        let upLeftNode: NodeLocation = NodeLocation(row: node.row - 1, column: node.column - 1)
        
        if(isValidNode(upNode)) {
            neighbors.append(upNode)
        }
        if(isValidNode(upRightNode)) {
            neighbors.append(upRightNode)
        }
        if(isValidNode(rightNode)) {
            neighbors.append(rightNode)
        }
        if(isValidNode(downRightNode)) {
            neighbors.append(downRightNode)
        }
        if(isValidNode(downNode)) {
            neighbors.append(downNode)
        }
        if(isValidNode(downLeftNode)) {
            neighbors.append(downLeftNode)
        }
        if(isValidNode(leftNode)) {
            neighbors.append(leftNode)
        }
        if(isValidNode(upLeftNode)) {
            neighbors.append(upLeftNode)
        }
        
        return neighbors
    }
    
    func executeBFS() -> Bool {
        switch(bfsState) {
        case .Init:
            let start = getStartCell()
            
            self[start].state.distance = 0
            self[start].state.parentNode = nil
            self[start].state.visitedState = .InQueue
            Q.append(start)
            
            bfsState = .Loop
            return false
            
        case .Loop:
            if let node = Q.first {
                if let adjNode = getAdjacentValidUnvisitedNeighbor(node) {
                    self[adjNode].state.distance = self[node].state.distance + 1
                    self[adjNode].state.parentNode = node
                    self[adjNode].state.visitedState = .InQueue
                    Q.append(adjNode)
                    
                    if adjNode == getEndCell() {
                        bfsState = .Done
                        return true
                    }
                }
                else {
                    self[node].state.visitedState = .Processed
                    Q.removeFirst()
                }
                
                return false
            }
            
            bfsState = .Done
            return true
            
        case .Done:
            return true
        }
    }
    
    func executeDFS() -> Bool {
        switch(bfsState) {
        case .Init:
            let start = getStartCell()
            
            self[start].state.distance = 0
            self[start].state.parentNode = nil
            self[start].state.visitedState = .InQueue
            Q.insert(start, atIndex: 0)
            
            bfsState = .Loop
            return false
            
        case .Loop:
            if let node = Q.first {
                if let adjNode = getAdjacentValidUnvisitedNeighbor(node) {
                    self[adjNode].state.distance = self[node].state.distance + 1
                    self[adjNode].state.parentNode = node
                    self[adjNode].state.visitedState = .InQueue
                    Q.insert(adjNode, atIndex: 0)
                    
                    if adjNode == getEndCell() {
                        bfsState = .Done
                        return true
                    }
                }
                else {
                    self[node].state.visitedState = .Processed
                    Q.removeFirst()
                }
                
                return false
            }
            
            bfsState = .Done
            return true
            
        case .Done:
            return true
        }
    }
    
    func executeAStar() -> Bool {
        /* Shortest distance from start to x. */
        func G(node: NodeLocation) -> Double {
            let pathLength = Double(getPathLength(getPath(getStartCell(), endNode: node)))
            return pathLength
        }
        
        /* Straightline distance from x to goal. */
        func H(node: NodeLocation) -> Double {
            let endCell = getEndCell()

            // Manhattan distance
            let distance = abs(endCell.row - node.row) + abs(endCell.column - node.column)
            
            return Double(distance)
        }
        
        /* Total distance from start to goal. */
        func F(node: NodeLocation) -> Double {
            let g = G(node)
            let h = H(node)
            let total = g + h
            return total
        }
        
        /* Open needs to be ordered based on lowest path length. */
        func addToOpen(node: NodeLocation) {
            OPEN.append(node)
            reorderOpen()
        }
        
        func reorderOpen() {
            OPEN.sortInPlace { (node1: NodeLocation, node2: NodeLocation) -> Bool in
                return self[node1].state.distance < self[node2].state.distance
            }
        }
        
        func removeNodeFromOpen(node: NodeLocation) {
            OPEN = OPEN.filter { openNode in
                return !(openNode == node)
            }
            reorderOpen()
        }
        
        switch aStarState {
        case .Init:
            let start = getStartCell()
        
            self[start].state.parentNode = nil
            self[start].state.visitedState = .InQueue
            OPEN.insert(start, atIndex: 0)
            
            aStarState = .Loop
            return false
            
        case .Loop:
            
            if let node = OPEN.first {
                for adjNode in getAdjacentValidNeighbors(node) {
                    if node == getEndCell() {
                        aStarState = .Done
                        return true
                    }
                    
                    if self[adjNode].state.visitedState == .Unvisited {
                        self[adjNode].state.parentNode = node
                        self[adjNode].state.distance = G(node) + 1 + H(adjNode)
                        self[adjNode].state.visitedState = .InQueue
                        addToOpen(adjNode)
                    }
                    else if self[adjNode].state.visitedState == .InQueue {
                        if G(node) + 1 < G(adjNode) {
                            self[adjNode].state.parentNode = node
                            self[adjNode].state.distance = G(node) + 1 + H(adjNode)
                            reorderOpen()
                        }
                    }
                }
                
                removeNodeFromOpen(node)
                self[node].state.visitedState = .Processed
                
                return false
            }
            
            aStarState = .Done
            return true
            
        case .Done:
            return true
        }
    }
}

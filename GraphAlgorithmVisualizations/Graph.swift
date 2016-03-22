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
    var distance : Int
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
    
    
    init(numRowsCols: Int) {
        self.numRowsCols = numRowsCols
        resetNodeStates(numRowsCols)

        self[0, 0].type = .Start
        self[numRowsCols - 1, numRowsCols - 1].type = .End
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
    
    func resetNodeStates(numRowsCols: Int) {
        let defaultState = CellState(visitedState: .Unvisited, distance: Int.max, parentNode: nil)
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
        var path: [NodeLocation] = []
        
        var cell: NodeLocation? = getEndCell()
        while let solutionCell = cell {
            path.append(solutionCell)
            cell = self[solutionCell].state.parentNode
        }
        
        return path
    }
    
    /********** CellState **********/
    
    func nodeDistance(node: NodeLocation) -> Int? {
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
        let rightNode: NodeLocation = NodeLocation(row: node.row, column: node.column + 1)
        let downNode: NodeLocation = NodeLocation(row: node.row + 1, column: node.column)
        let leftNode: NodeLocation = NodeLocation(row: node.row, column: node.column - 1)
        
        if(isValidAndUnvisitedNode(upNode)) {
            return upNode
        }
        if(isValidAndUnvisitedNode(rightNode)) {
            return rightNode
        }
        if(isValidAndUnvisitedNode(downNode)) {
            return downNode
        }
        if(isValidAndUnvisitedNode(leftNode)) {
            return leftNode
        }
        
        return nil
    }
    
    func executeBFS() {
        let start = getStartCell()
        var Q: [NodeLocation] = []
        
        self[start].state.distance = 0
        self[start].state.parentNode = nil
        self[start].state.visitedState = .InQueue
        Q.append(start)
        
        mainLoop: while let node = Q.first {
            if node == getEndCell() {
                break mainLoop
            }
            
            if let adjNode = getAdjacentValidUnvisitedNeighbor(node) {
                self[adjNode].state.distance = self[node].state.distance + 1
                self[adjNode].state.parentNode = node
                self[adjNode].state.visitedState = .InQueue
                Q.append(adjNode)
            }
            else {
                self[node].state.visitedState = .Processed
                Q.removeFirst()
            }
        }
    }
    
    func executeDFS() {
        let start = getStartCell()
        var Q: [NodeLocation] = []
        
        self[start].state.distance = 0
        self[start].state.parentNode = nil
        self[start].state.visitedState = .InQueue
        Q.insert(start, atIndex: 0)
        
        while let node = Q.first {
            if node == getEndCell() {
                break
            }
            
            if let adjNode = getAdjacentValidUnvisitedNeighbor(node) {
                self[adjNode].state.distance = self[node].state.distance + 1
                self[adjNode].state.parentNode = node
                self[adjNode].state.visitedState = .InQueue
                Q.insert(adjNode, atIndex: 0)
            }
            else {
                self[node].state.visitedState = .Processed
                Q.removeFirst()
            }
        }
    }
}

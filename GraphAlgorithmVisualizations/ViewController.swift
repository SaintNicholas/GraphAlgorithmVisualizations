//
//  ViewController.swift
//  aStar
//
//  Created by Goote, Nick on 3/20/16.
//  Copyright © 2016 Goote, Nick. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myCollectionViewFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var myCellTypePicker: StringPicker!
    @IBOutlet weak var mySearchTypePicker: StringPicker!
    
    @IBAction func executeButton(sender: UIButton) {
        myCollectionView.userInteractionEnabled = false
        myGraph.executeBFS(myGraph.getStartCell())
        myCollectionView.reloadData()
    }
    
    enum searchTypes: String {
        case BFS = "BFS"
        case DFS = "DFS"
        case AStar = "A*"
    }
    let numRowsColumns: Int = 20
    var myGraph: Graph!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myGraph = Graph(numRowsCols: numRowsColumns)
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        myCellTypePicker.delegate = myCellTypePicker
        myCellTypePicker.dataSource = myCellTypePicker
        myCellTypePicker.setPossiblePicks(myGraph.getPossibleCellStates())
        
        mySearchTypePicker.delegate = mySearchTypePicker
        mySearchTypePicker.dataSource = mySearchTypePicker
        mySearchTypePicker.setPossiblePicks([searchTypes.BFS.rawValue, searchTypes.DFS.rawValue, searchTypes.AStar.rawValue])
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numRowsColumns
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numRowsColumns
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.grayColor().CGColor

        let cellCoordinate = GraphCoordinate(section: indexPath.section, row: indexPath.row)
        switch(myGraph.cellTypeAtCoordinate(cellCoordinate)) {
        case .Wall:
            cell.backgroundColor = UIColor.grayColor()
        case .Start:
            cell.backgroundColor = UIColor.greenColor()
        case .End:
            cell.backgroundColor = UIColor.redColor()
        default:
            if myGraph.getSolutionPath().contains(cellCoordinate) {
                cell.backgroundColor = UIColor.purpleColor()
            }
            else if myGraph.visitedAtCoordinate(cellCoordinate) {
                cell.backgroundColor = UIColor.yellowColor()
            }
            else {
                cell.backgroundColor = UIColor.whiteColor()
            }
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect: CGRect = myCollectionView.bounds
        let screenWidth: CGFloat = screenRect.size.width
        let cellWidth = screenWidth / CGFloat(numRowsColumns)
        let cellSize: CGSize = CGSizeMake(cellWidth, cellWidth)
        
        return cellSize;
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch myCellTypePicker.getSelectedPick() {
            case "Start":
            myGraph.setStartCell((indexPath.section, indexPath.row))
            case "End":
            myGraph.setEndCell((indexPath.section, indexPath.row))
            case "Empty":
            myGraph.setEmptyCell((indexPath.section, indexPath.row))
            default:
            myGraph.setWallCell((indexPath.section, indexPath.row))
        }
        myCollectionView.reloadData()
    }
}

class StringPicker : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var myCellTypePickerData : [String] = []
    var myCellTypePickerDataSelected : String = ""
    
    func setPossiblePicks(possiblePicks: [String]) {
        myCellTypePickerData = possiblePicks
        myCellTypePickerDataSelected = myCellTypePickerData[0]
    }
    
    @objc func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myCellTypePickerData.count
    }
    
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myCellTypePickerData[row]
    }
    
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        myCellTypePickerDataSelected = myCellTypePickerData[row]
    }
    
    func getSelectedPick() -> String {
        return myCellTypePickerDataSelected
    }
}

struct GraphCoordinate : Equatable {
    let section: Int
    let row: Int
}

func ==(lhs: GraphCoordinate, rhs: GraphCoordinate) -> Bool {
    return lhs.row == rhs.row && lhs.section == rhs.section
}

struct NodeData {
    var distance: Int
    var parent: GraphCoordinate?
    var visited: Bool
}

class Graph {
    enum CellState: String {
        case Wall = "Wall"
        case Empty = "Empty"
        case Start = "Start"
        case End = "End"
    }
    var cellStates: [[CellState]] = []
    let numRowsCols: Int
    var nodeData: [[NodeData]] = []
    
    init(numRowsCols: Int) {
        self.numRowsCols = numRowsCols
        resetCellStates(numRowsCols)
        resetNodes(numRowsCols)
        
        /* Default start, end location */
        cellStates[0][0] = .Start
        cellStates[numRowsCols - 1][numRowsCols - 1] = .End
    }
    
    func resetCellStates(numRowsCols: Int) {
        cellStates = Array(count: numRowsCols, repeatedValue: Array(count: numRowsCols, repeatedValue: CellState.Empty))
    }
    
    func resetNodes(numRowsCols: Int) {
        let node = NodeData(distance: Int.max, parent: nil, visited: false)
        nodeData = Array(count: numRowsCols, repeatedValue: Array(count: numRowsCols, repeatedValue: node))
    }
    
    func clearExistingCellsOfType(type: CellState) {
        for section in 0..<numRowsCols {
            if let col = cellStates[section].indexOf(type) {
                cellStates[section][col] = .Empty
            }
        }
    }
    
    func getExistingCellOfType(type: CellState) -> GraphCoordinate? {
        for section in 0..<numRowsCols {
            if let col = cellStates[section].indexOf(type) {
                return GraphCoordinate(section: section, row: col)
            }
        }
        return nil
    }

    func setStartCell(cell: (Int, Int)) {
        clearExistingCellsOfType(.Start)
        cellStates[cell.0][cell.1] = .Start
    }
    
    func getStartCell() -> GraphCoordinate {
        if let start = getExistingCellOfType(.Start) {
            return start
        }
        return GraphCoordinate(section: 0, row: 0)
    }
    
    func setEndCell(cell: (Int, Int)) {
        clearExistingCellsOfType(.End)
        cellStates[cell.0][cell.1] = .End
    }
    
    func getEndCell() -> GraphCoordinate {
        if let end = getExistingCellOfType(.End) {
            return end
        }
        return GraphCoordinate(section: numRowsCols - 1, row: numRowsCols - 1)
    }
    
    func setEmptyCell(cell: (Int, Int)) {
        cellStates[cell.0][cell.1] = .Empty
    }
    
    func setWallCell(cell: (Int, Int)) {
        cellStates[cell.0][cell.1] = .Wall
    }
    
    func getPossibleCellStates() -> [String] {
        return [CellState.Wall.rawValue, CellState.Empty.rawValue, CellState.Start.rawValue, CellState.End.rawValue]
    }
    
    func cellTypeAtCoordinate(coordinate: GraphCoordinate) -> CellState {
        return cellStates[coordinate.section][coordinate.row]
    }
    
    func visitedAtCoordinate(coordinate: GraphCoordinate) -> Bool {
        return nodeData[coordinate.section][coordinate.row].visited
    }
    
    func solutionPathAtCoordinate(coordinate: GraphCoordinate) -> Bool {
        return nodeData[coordinate.section][coordinate.row].parent != nil
    }
    
    func getSolutionPath() -> [GraphCoordinate] {
        var path: [GraphCoordinate] = []
        
        var cell: GraphCoordinate? = getEndCell()
        while let solutionCell = cell {
            path.append(solutionCell)
            cell = nodeData[solutionCell.section][solutionCell.row].parent
        }
        
        return path
    }
    
    
    
    
    
    
    func isValidNode(node: GraphCoordinate) -> Bool {
        if node.section >= 0 &&
            node.section < numRowsCols &&
            node.row >= 0 &&
            node.row < numRowsCols &&
            cellStates[node.section][node.row] != .Wall {
            return true
        }
        return false
    }
    
    func isUnvisitedNode(node: GraphCoordinate) -> Bool {
        return !nodeData[node.section][node.row].visited
    }
    
    func isValidAndUnvisitedNode(node: GraphCoordinate) -> Bool {
        return isValidNode(node) && isUnvisitedNode(node)
    }
    
    func getAdjacentValidUnvisitedNeighbors(node: GraphCoordinate) -> [GraphCoordinate] {
        var nodes: [GraphCoordinate] = []
        
        // Up
        let upNode: GraphCoordinate = GraphCoordinate(section: node.section - 1, row: node.row)
        let rightNode: GraphCoordinate = GraphCoordinate(section: node.section, row: node.row + 1)
        let downNode: GraphCoordinate = GraphCoordinate(section: node.section + 1, row: node.row)
        let leftNode: GraphCoordinate = GraphCoordinate(section: node.section, row: node.row - 1)
        
        if(isValidAndUnvisitedNode(upNode)) {
            nodes.append(upNode)
        }
        if(isValidAndUnvisitedNode(rightNode)) {
            nodes.append(rightNode)
        }
        if(isValidAndUnvisitedNode(downNode)) {
            nodes.append(downNode)
        }
        if(isValidAndUnvisitedNode(leftNode)) {
            nodes.append(leftNode)
        }
        
        return nodes
    }
    
    func executeBFS(start: GraphCoordinate) {
        var Q: [GraphCoordinate] = []
        
        nodeData[start.section][start.row].distance = 0
        nodeData[start.section][start.row].parent = nil
        nodeData[start.section][start.row].visited = true
        Q.append(start)
        
        mainLoop: while true {
            guard !Q.isEmpty else {
                break
            }
            
            let node = Q.removeFirst()
            
            for adjNode in getAdjacentValidUnvisitedNeighbors(node) {
                nodeData[adjNode.section][adjNode.row].distance = nodeData[node.section][node.row].distance + 1
                nodeData[adjNode.section][adjNode.row].parent = node
                nodeData[adjNode.section][adjNode.row].visited = true
                Q.append(adjNode)
                
                if node == getEndCell() {
                    break mainLoop
                }
            }
        }
    }
}

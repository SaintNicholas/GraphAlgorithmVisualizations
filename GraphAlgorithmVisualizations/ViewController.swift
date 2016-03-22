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
        myGraph.executeBFS()
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

        let nodeLocation = NodeLocation(row: indexPath.section, column: indexPath.row)
        switch(myGraph.cellType(nodeLocation)) {
        case .Wall:
            cell.backgroundColor = UIColor.grayColor()
        case .Start:
            cell.backgroundColor = UIColor.greenColor()
        case .End:
            cell.backgroundColor = UIColor.redColor()
        default:
            if myGraph.getSolutionPath().contains(nodeLocation) {
                cell.backgroundColor = UIColor.purpleColor()
            }
            else if myGraph.nodeProcessed(nodeLocation) {
                cell.backgroundColor = UIColor.blueColor()
            }
            else if myGraph.nodeInQueue(nodeLocation) {
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
        let nodeLocation = NodeLocation(row: indexPath.section, column: indexPath.row)
        switch myCellTypePicker.getSelectedPick() {
            case "Start":
            myGraph.setStartCell(nodeLocation)
            case "End":
            myGraph.setEndCell(nodeLocation)
            case "Empty":
            myGraph.setEmptyCell(nodeLocation)
            default:
            myGraph.setWallCell(nodeLocation)
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



//
//  MindMapsViewController.swift
//  MindMaps
//
//  Created by Muhammad Ibrahim on 16/04/2020.
//  Copyright © 2020 ARCeus. All rights reserved.
//

import UIKit

class MindMapsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var mappingTable: [MappingTable]? {
        didSet{
            for map in mappingTable!
            {
                if map.endpg != nil{
                    if let url = URL(string: K.baseURl + "\(format(number: Int(map.sno)) )-\(format(number: map.vno)).png" )
                    {
                        mindmaps.append(MindMap(chapterNo: map.sno ,verseNo: map.vno, mindMapUrl: url))
                    }
                }
            }
        }
    }
    
    var mindmaps = [MindMap]()
    
    var selectedVerse: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        
        tableView.register(UINib(nibName: K.nib.MindMapCell, bundle: nil), forCellReuseIdentifier: K.Cell.mindMapsCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToRow(at: selectedVerse!)
        pickerView.selectRow(selectedVerse!, inComponent: 0, animated: true)
        
    }
    
    func scrollToRow(at index: Int)
    {
        if mappingTable != nil {
            if mappingTable![index].startpg != nil {
                let indexPath = IndexPath(row: mappingTable![index].startpg! - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func format(number: Int) -> String
    {
        switch number {
        case 1...9:
            return "00\(number)"
        case 10...99:
            return "0\(number)"
        default:
            return "\(number)"
        }
    }
}

// MARK:- Table View Delegate
extension MindMapsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- Table View DataSource
extension MindMapsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MappingTable.totalMindMaps>0 ? MappingTable.totalMindMaps : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.mindMapsCell, for: indexPath) as? MindMapCell {
            if !mindmaps.isEmpty
            {
                cell.mindMap = mindmaps[indexPath.row]
            }
            return cell
        }
    
        return UITableViewCell()
    }
}

// MARK:- PickerView Delegate & DataSource
extension MindMapsViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mindmaps.count>0 ? "\(mindmaps[row].verseNo)" : "0"
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mindmaps.count>0 ? mindmaps.count : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        scrollToRow(at: row)
    }
    
}

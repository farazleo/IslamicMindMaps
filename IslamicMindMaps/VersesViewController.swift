//
//  VersesViewController.swift
//  MindMaps
//
//  Created by Muhammad Ibrahim on 25/04/2020.
//  Copyright © 2020 ARCeus. All rights reserved.
//

import UIKit
import CSV
import SQLite

class VersesViewController: UIViewController {

    var verses = [String]()
    var mappingTable = [MappingTable]()
    var chapter: Chapter?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let stringPath =  Bundle.main.path(forResource: K.DB.name, ofType: K.DB.fileType)
        
        let db = try! Connection(stringPath!)
        
        let suraId = Expression<Int64>(K.DB.Quran.sura)
        let text = Expression<String>(K.DB.Quran.text)

        let quranTable = Table(K.DB.Quran.tableName)
       
        
        let surahVerses = quranTable.filter(suraId == chapter!.id)
        
        for verse in try! db.prepare(surahVerses) {
            verses.append(verse[text])
        }
        tableView.reloadData()
        loadMappingTable()
    }
    
    func loadMappingTable()
    {
        MappingTable.totalMindMaps = 0
        let csvPath = Bundle.main.path(forResource: K.MappingFile.name, ofType: K.MappingFile.type)
        let stream = InputStream(fileAtPath: csvPath!)!
        do {
            let reader = try CSVReader(stream: stream, hasHeaderRow: true)
            let decoder = CSVRowDecoder()
            while reader.next() != nil {
                if reader["sno"]! == "\(chapter!.id)" {
                    let row = try decoder.decode(MappingTable.self, from: reader)
                    mappingTable.append(row)
                    if row.endpg != nil {
                        MappingTable.totalMindMaps = row.endpg!
                    }
                    //print("Decoded")
                }
            }
            //print(MappingTable.totalMindMaps)
        } catch {
            print("Invalid row")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destinationVC = segue.destination as? MindMapsViewController {
            if !mappingTable.isEmpty {
                destinationVC.mappingTable = mappingTable
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.selectedVerse = indexPath.row
                }
            }
        }
    }
}

//MARK:- Table View Delegate
extension VersesViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: K.Segue.versesToMindMap, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- Table View Datasource
extension VersesViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.versesCell, for: indexPath)
        cell.textLabel?.text = verses[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.08 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
}


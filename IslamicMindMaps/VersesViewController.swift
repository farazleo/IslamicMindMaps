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
import AVFoundation
import SwipeCellKit
import RealmSwift

class VersesViewController: UIViewController {
    
    var player: AVPlayer!
    var playerToggleState = 1
    var surahAudioURL:URL?
    var verses = [String]()
    var mappingTable = [MappingTable]()
    var chapter: Chapter?
    var dbManager = DBManager()
    var saveMindMap = SaveMindMap()
    let realm = try! Realm()
    
    
    @IBOutlet weak var audioPlayerButton: UIButton!
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
        
        if playerToggleState == 1 {
            player.play()
            playerToggleState = 2
            audioPlayerButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audioPlayerButton.setTitle("Pause", for: .normal)
            
        } else {
            player.pause()
            playerToggleState = 1
            audioPlayerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            audioPlayerButton.setTitle("Play", for: .normal)
        }
        
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        dbManager.delegateVerses = self
        dbManager.getVerses(of: chapter!.id)
        loadMappingTable()
        tableView.separatorStyle = .none
        surahAudioURL = createAudioURLSurahLevel(rowIndex: Int(chapter!.id))
        
        let playerItem = CachingPlayerItem(url: surahAudioURL!)
        
        player = AVPlayer(playerItem:playerItem)
        player.volume = 0.75
        
        if (chapter?.id != 1 && chapter?.id != 9) {
            verses.insert("﷽", at: 0)
        }
        
        saveMindMap.delegate = self
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    func format(number: Int64) -> String
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
    
    func createAudioURL (rowIndex: Int) -> URL {
        let url = URL(string: K.audioBaseURl + "\(format(number: Int64(chapter?.id ?? 0)) )\(format(number: Int64(rowIndex))).mp3" )
        return url!
    }
    
    
    func createAudioURLSurahLevel (rowIndex: Int) -> URL {
        let url = URL(string: K.audioSurahLevelBaseURl + "\(format(number: Int64(chapter?.id ?? 0))).mp3" )
        return url!
        
    }
    
    func playAudio(url:URL) {
        
        
        
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
                    destinationVC.selectedVerse = indexPath.row - 1
                }
            }
        }
    }
}

// MARK:- Verses Data Delegate
extension VersesViewController: VersesDataDelegate {
    func didFailWithError(_ dbManager: DBManager, with error: String) {
        print(error)
    }
    
    func didUpdateVerses(_ dbManager: DBManager, with versesArray: [String])
    {
        verses = versesArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK:- Table View Delegate
extension VersesViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        let audioURL = createAudioURL(rowIndex: indexPath.row + 1)
        //        playAudio(url: audioURL)
        if indexPath.row > 0 {
            performSegue(withIdentifier: K.Segue.versesToMindMap, sender: self)
        }
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
        if indexPath.row > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.versesCell, for: indexPath) as! SwipeTableViewCell
            cell.delegate = self
            let attributedString = NSMutableAttributedString(string: verses[indexPath.row])
            
            // *** Create instance of `NSMutableParagraphStyle`
            let paragraphStyle = NSMutableParagraphStyle()
            
            // *** set LineSpacing property in points ***
            // Whatever line spacing you want in points
            paragraphStyle.lineSpacing = 26
            paragraphStyle.alignment = NSTextAlignment.center
            
            // *** Apply attribute to string ***
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            // *** Set Attributed String to your label ***
            
            
            cell.textLabel?.attributedText = attributedString
            cell.textLabel?.numberOfLines = 0
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.versesCell, for: indexPath)
            
            let attributedString = NSMutableAttributedString(string: verses[indexPath.row])
            
            // *** Create instance of `NSMutableParagraphStyle`
            let paragraphStyle = NSMutableParagraphStyle()
            
            // *** set LineSpacing property in points ***
            // Whatever line spacing you want in points
            paragraphStyle.lineSpacing = 26
            paragraphStyle.alignment = NSTextAlignment.center
            
            // *** Apply attribute to string ***
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            // *** Set Attributed String to your label ***
            
            
            cell.textLabel?.attributedText = attributedString
            cell.textLabel?.numberOfLines = 0
            
            return cell
        }
        
    }
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        cell.alpha = 0
    //
    //        UIView.animate(
    //            withDuration: 0.5,
    //            delay: 0.08 * Double(indexPath.row),
    //            animations: {
    //                cell.alpha = 1
    //        })
    //    }
}

// MARK:- Swipe Cell Delegate
extension VersesViewController: SwipeTableViewCellDelegate, SaveMindMapDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let saveAction = SwipeAction(style: .default, title: "Save") { action, indexPath in
            self.saveVerseMindMap(of: indexPath.row)
        }
        
        // customize the action appearance
        saveAction.image = UIImage(systemName: "arrow.down.doc.fill")
        
        return [saveAction]
    }
    
    func saveVerseMindMap(of verseNo: Int)
    {
        if !mappingTable.isEmpty{
            if let endPage = mappingTable[verseNo-1].endpg, let startPage = mappingTable[verseNo-1].startpg {
                let mindMaps = [startPage,endPage]
                let totalMindMaps = endPage - startPage
                if totalMindMaps > 0{
                    for map in mindMaps{
                        let chNo = format(number: chapter!.id)
                        let mapNo = format(number: Int64(map))
                        saveMindMap.fetchImage(of: "\(chNo)-\(mapNo)", verse: verseNo)
                    }
                }
                else{
                    let chNo = format(number: chapter!.id)
                    let mapNo = format(number: Int64(startPage))
                    saveMindMap.fetchImage(of: "\(chNo)-\(mapNo).png", verse: verseNo)
                }
            }
        }
        else
        {
            view.makeToast("Mind Map Not Avaliable Yet")
        }
    }
    
    func didSaveMindMap(with name: String, verse: Int)
    {
        print(name)
        let savedUrl = SavedMindMapsUrls()
        savedUrl.fileName = name
        savedUrl.surahName = chapter!.romanName
        savedUrl.verseNo = "\(verse)"
        DispatchQueue.main.async {
            self.view.makeToast("Mind Map Saved")
            do{
                try self.realm.write{
                    self.realm.add(savedUrl)
                }
            }
            catch{
                print("Error while saving data \(error.localizedDescription)")
            }
        }
        
    }
}

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


class VersesViewController: UIViewController {
    
    var player: AVPlayer!
    var playerToggleState = 1
    var surahAudioURL:URL?
    var verses = [String]()
    var mappingTable = [MappingTable]()
    var chapter: Chapter?
    var dbManager = DBManager()
    

    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
        
        if playerToggleState == 1 {
            player.play()
            playerToggleState = 2
            
        } else {
            player.pause()
            playerToggleState = 1
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
        
    
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        player = nil
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
                    destinationVC.selectedVerse = indexPath.row
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



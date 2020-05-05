//
//  dbManager.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 19/04/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import Foundation
import SQLite

protocol ChaptersDataDelegate {
    func didUpdateChapters(_ dbManager: DBManager, with chaptersArray: [Chapter])
    func didFailWithError(_ dbManager: DBManager, with error: String)
}

protocol VersesDataDelegate {
    func didUpdateVerses(_ dbManager: DBManager, with versesArray: [String])
    func didFailWithError(_ dbManager: DBManager, with error: String)
}

struct DBManager {
    
    
    var delegateChapters: ChaptersDataDelegate?
    var delegateVerses: VersesDataDelegate?
   
    func dataFetch() {
        var chaptersArray: [Chapter]=[]
        let id = Expression<Int64>("id")
        let romanName = Expression<String>("romanname")
        let arabicName = Expression<String>("arabicname")
        let totalVerses = Expression<Int64>("totalverses")
        let category = Expression<String>("chaptertype")
        
        if let databaseFilePath = Bundle.main.path(forResource: K.DB.name, ofType: K.DB.fileType){
            
            let db = try! Connection(databaseFilePath)
            let chapters = Table("chapter")
            
            for chapter in try! db.prepare(chapters) {
                let myChapter=Chapter(id:chapter[id],romanName:chapter[romanName],arabicName: chapter[arabicName],totalVerses:chapter[totalVerses],category:chapter[category])
                chaptersArray.append(myChapter)
                
            }
            self.delegateChapters?.didUpdateChapters(self, with: chaptersArray)
        }
        else {
            delegateChapters?.didFailWithError(self, with: "Error finding DataBase")
        }
        
    }
    
    func getVerses(of chapterNo: Int64)
    {
        var verses = [String]()
        if let dataBaseFilePath =  Bundle.main.path(forResource: K.DB.name, ofType: K.DB.fileType) {
            
            let db = try! Connection(dataBaseFilePath)
            
            let suraId = Expression<Int64>(K.DB.Quran.sura)
            let text = Expression<String>(K.DB.Quran.text)
            
            let quranTable = Table(K.DB.Quran.tableName)
            
            
            let surahVerses = quranTable.filter(suraId == chapterNo)
            
            for verse in try! db.prepare(surahVerses) {
                verses.append(verse[text])
            }
            delegateVerses?.didUpdateVerses(self, with: verses)
        }
        else{
            delegateVerses?.didFailWithError(self, with: "Failed to load verses")
        }
    }
    
}

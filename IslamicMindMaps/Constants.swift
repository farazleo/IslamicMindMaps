//
//  Constants.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 18/04/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import Foundation

struct K {
    
    static let baseURl = "http://data.alhudamedia.com/apps/com.alhuda.mindmaps/images/"
    static let audioSurahLevelBaseURl = "http://server11.mp3quran.net/Othmn/"
    static let audioBaseURl = "https://everyayah.com/data/Ayman_Sowaid_64kbps/"
    
    
    struct MappingFile
    {
        static let name = "verseToMindMap"
        static let type = "csv"
    }
    
    struct DB
    {
        static let name = "quranlite"
        static let fileType = "db"
        
        struct Chapter
        {
            static let tableName = "chapter"
            static let id = "id"
            static let totalVerses = "totalverses"
            static let romanName = "romanname"
        }
        struct Quran {
            static let tableName = "quran"
            static let text = "text"
            static let sura = "sura"
        }
    }
    
    struct Segue
    {
        static let chaptersToVerses = "showVerses"
        static let versesToMindMap = "showMindMaps"
    }
    
    struct Cell {
        static let chaptersCell = "ChaptersCell"
        static let mindMapsCell = "MindMapsCell"
        static let versesCell = "VersesCell"
        static let savedMindMapsCell = "SavedMindMapsCell"
    }
    
    struct nib {
        static let MindMapsCell = "MindMapCell"
        static let ChaptersCell = "ChaptersCell"
        static let VersesCell = "VersesCell"
        static let SavedMindMapsCell = "SavedMindMapsCell"
    }
    
    
}


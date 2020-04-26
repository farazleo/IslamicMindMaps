//
//  Chapters.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 26/04/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import Foundation

struct Chapter {
    
    var id:Int64
    var romanName:String
    var arabicName:String
    var totalVerses:Int64
    
    init(id:Int64 ,romanName:String,arabicName:String,totalVerses:Int64){
        self.id=id
        self.romanName=romanName
        self.arabicName=arabicName
        self.totalVerses=totalVerses
        
    }
    
}

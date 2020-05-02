//
//  MappingTable.swift
//  MindMaps
//
//  Created by Muhammad Ibrahim on 25/04/2020.
//  Copyright © 2020 ARCeus. All rights reserved.
//

import Foundation

struct MappingTable: Decodable {
    let sno: Int
    let vno: Int
    let startpg: Int?
    let endpg: Int?
    
    static var totalMindMaps = 0
}

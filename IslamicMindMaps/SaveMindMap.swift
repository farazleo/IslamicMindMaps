//
//  SaveMindMap.swift
//  IslamicMindMaps
//
//  Created by Muhammad Ibrahim on 15/06/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import Foundation
import UIKit


protocol SaveMindMapDelegate {
    func didSaveMindMap(with url: String, verse: Int)
}

struct SaveMindMap {
    
    var delegate: SaveMindMapDelegate?
    
    
    var mindMapName: String = ""
    var verseNo = 0
    mutating func fetchImage(of mindMap: String, verse: Int)
    {
        let stringUrl = K.baseURl+mindMap
        mindMapName = mindMap
        verseNo = verse
        performRequest(with: stringUrl)
    }
    
    func performRequest(with stringUrl: String)
    {
        //1 create a URL
        if let url = URL(string: stringUrl)
        {
            // 2 create a URL Session
            let session = URLSession(configuration: .default)
            
            
            // 3 give session a task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                    return
                }
                if let imageData = data
                {
                    if let mindMapImage = UIImage(data: imageData) {
                        self.saveContent(of: mindMapImage)
                    }
                    
                }
            }
            
            // 4 start the task
            task.resume()
        }
    }
    
    func saveContent(of image: UIImage)
    {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // choose a name for your image
        let fileName = mindMapName
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.jpegData(compressionQuality:  1.0),
          !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                
                print("file saved")
                delegate?.didSaveMindMap(with: mindMapName, verse: verseNo)
            } catch {
                print("error saving file:", error)
            }
        }
        else
        {
            print("File already exists")
        }
    }
}

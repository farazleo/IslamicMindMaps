//
//  SavedViewController.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 05/05/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SavedViewController : UIViewController {
    
    var savedUrls: Results<SavedMindMapsUrls>!
    
    let realm = try! Realm()
    
    var mindMapImages = [UIImage]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "SavedMindMapsCell", bundle: nil), forCellWithReuseIdentifier: "SavedMindMapsCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedUrls()
    }
    func loadSavedUrls()
    {
        savedUrls = realm.objects(SavedMindMapsUrls.self)
        for url in savedUrls {
            mindMapImages.append(getImage(imageName: url.fileName))
        }
        collectionView.reloadData()
    }
    
    func getImage(imageName : String)-> UIImage{
        let fileManager = FileManager.default
        // Here using getDirectoryPath method to get the Directory path
        let imagePath = (getDirectoryPath() as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("No Image available")
            return UIImage.init(named: "underConstruction")! // Return placeholder image here
        }
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}

extension SavedViewController: UICollectionViewDelegate
{
    
}

extension SavedViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedMindMapsCell", for: indexPath) as? SavedMindMapsCell {
            
            cell.mindMapLabel.text = savedUrls[indexPath.row].surahName+" \(savedUrls[indexPath.row].verseNo)"
            cell.mindMapLabel.numberOfLines = 0
            cell.mindMapImageView.image = mindMapImages[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
}

extension SavedViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height-200
        return CGSize(width: width, height: height)
    }
}

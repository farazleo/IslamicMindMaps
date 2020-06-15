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
import Toast_Swift

class SavedViewController : UIViewController, UIGestureRecognizerDelegate {
    
    var savedUrls: Results<SavedMindMapsUrls>!
    
    let realm = try! Realm()
    
    var mindMapImages = [UIImage]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "SavedMindMapsCell", bundle: nil), forCellWithReuseIdentifier: "SavedMindMapsCell")
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delaysTouchesBegan = true
        longPressRecognizer.delegate = self
        collectionView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer)
    {
        let point = gestureReconizer.location(in: collectionView)
        if let indexPath = self.collectionView?.indexPathForItem(at: point)
        {
            if gestureReconizer.state == UIGestureRecognizer.State.ended
            {
                let alert = UIAlertController(title: "Delete MindMap?", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {(action) in
                    
                    print(indexPath.row)
                    do{
                        try self.realm.write
                        {
                            self.deleteImage(named: self.savedUrls[indexPath.row].fileName)
                            self.mindMapImages.remove(at: indexPath.row)
                            self.realm.delete(self.savedUrls[indexPath.row])
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                self.view.makeToast("Mind Map Deleted!")
                            }
                        }
                    }catch{
                        print("could not delete data in realm")
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: "share", style: .default, handler: {(action) in
                    let imageToShare = [self.mindMapImages[indexPath.row]]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                    
                    // exclude some activity types from the list (optional)
                    activityViewController.excludedActivityTypes = [ .postToFacebook ]
                    activityViewController.isModalInPresentation = true
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: {
                    alert.view.superview?.isUserInteractionEnabled = true
                    alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
                })
            }
        }
        
    }
    
    @objc func dismissOnTapOutside(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedUrls()
    }
    func loadSavedUrls()
    {
        savedUrls = realm.objects(SavedMindMapsUrls.self)
        mindMapImages.removeAll()
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
    
    func deleteImage(named: String)
    {
        let fileManager = FileManager.default
        // Here using getDirectoryPath method to get the Directory path
        let imagePath = (getDirectoryPath() as NSString).appendingPathComponent(named)
        if fileManager.fileExists(atPath: imagePath){
            do{
                print(imagePath)
                try fileManager.removeItem(atPath: imagePath)
                print("image Deleted!")
            }
            catch{
                print("could not delete image")
            }
        }else{
            print("No Image available")
            // Return placeholder image here
        }
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

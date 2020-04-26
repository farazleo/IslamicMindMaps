//
//  ViewController.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 18/04/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import UIKit


class ChapterViewController: UIViewController {
    
    
    @IBOutlet var noItemView: UIView!
//    var chapterNames=["faraz","Ali","Usman","Haseeb","Muneeb","Ali","Usman","Haseeb","Muneeb","Ali","Usman","Haseeb","Muneeb"]
    var filteredChapterNamesArray=[Chapter]()
    var isSearching=false
    var chapters=[Chapter]()
    var myDbManager=dbManager()
    
    @IBOutlet weak var chapterTableView: UITableView!
    @IBOutlet weak var chapterSearchField: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chapterTableView.register(UINib(nibName:"TableViewCell", bundle: nil), forCellReuseIdentifier:K.reusableChapterCell)
        
        chapterTableView.dataSource=self
        chapterTableView.delegate=self
        chapterSearchField.delegate=self
        myDbManager.delegate=self
        myDbManager.dataFetch()
        chapterTableView.keyboardDismissMode = .onDrag
        
        
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        chapterTableView.endEditing(true)
    }
    
    
}

//MARK: - dbManagerDelegate

extension ChapterViewController:dbManagerDelegate{
    
    func didUpdateData(chapterArray: [Chapter]) {
        chapters=chapterArray
    }
    
    
}



//MARK: - UITableViewDelegate



extension ChapterViewController:UITableViewDataSource,UITableViewDelegate {
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        isSearching ? filteredChapterNamesArray.count:chapters.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: K.reusableChapterCell, for: indexPath) as! TableViewCell
        if isSearching{
            
            
            cell.romanName?.text=filteredChapterNamesArray[indexPath.row].romanName
            
            cell.arabicName?.text=filteredChapterNamesArray[indexPath.row].arabicName

        }
        else {
            cell.romanName?.text=chapters[indexPath.row].romanName
            cell.arabicName?.text=chapters[indexPath.row].arabicName
            
            
            
        }
        return cell
    }
    
    
}
extension ChapterViewController:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        isSearching=true
        filteredChapterNamesArray=chapters.filter({$0.romanName.contains(searchText)})
        
        if filteredChapterNamesArray.count==0{
            
            chapterTableView.backgroundView=noItemView
            chapterTableView.separatorStyle = .none
            
            
        }
        
        
        if (searchText.count==0 || filteredChapterNamesArray.count>0 ){
            if searchText.count==0 { isSearching=false}
            chapterTableView.backgroundView=nil
            chapterTableView.separatorStyle = UITableViewCell.SeparatorStyle(rawValue: 1)!
            
        }
        chapterTableView.reloadData()
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching=false
    }
    
    
}



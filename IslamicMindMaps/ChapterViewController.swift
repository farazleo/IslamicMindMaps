//
//  ViewController.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 18/04/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import UIKit


class ChapterViewController: UIViewController{
    
    
    @IBOutlet var noItemView: UIView!

    var filteredChapterNamesArray = [Chapter]()
    var isAllTabSelected = true
    var chapters = [Chapter]()
    var myDbManager = dbManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var chapterTableView: UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chapterTableView.register(UINib(nibName:"TableViewCell", bundle: nil), forCellReuseIdentifier:K.reusableChapterCell)
        
        chapterTableView.dataSource = self
        chapterTableView.delegate = self
        myDbManager.delegate = self
        myDbManager.dataFetch()
        chapterTableView.keyboardDismissMode = .onDrag
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Chapters"
        
   
        

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }

        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["All","Meccan","Medinan"]
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            // Fallback on earlier versions
        }
        
    }

 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        chapterTableView.endEditing(true)
    }
    
    var isSearchBarEmpty: Bool {
       return searchController.searchBar.text?.isEmpty ?? true
     }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
        
    }
    
    func filterContentForSearchTextWithCategory(_ searchText: String,
                                                _ category: String) {
        
        
        filteredChapterNamesArray = chapters.filter { (chapter: Chapter) -> Bool in
            
            let doesCategoryMatch = chapter.category == category
            
            if isSearchBarEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && chapter.romanName.lowercased().contains(searchText.lowercased())
            }
        }
        
        chapterTableView.reloadData()
    }
    func filterContentForSearchTextWithoutCategory(_ searchText: String,
                                                _ category: String) {
        
        
        filteredChapterNamesArray = chapters.filter { (chapter: Chapter) -> Bool in
            
            
            
            if isSearchBarEmpty {
                return true
            } else {
                return  chapter.romanName.lowercased().contains(searchText.lowercased())
            }
        }
        
        chapterTableView.reloadData()
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
        
        isFiltering ? filteredChapterNamesArray.count:chapters.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: K.reusableChapterCell, for: indexPath) as! TableViewCell
        if isFiltering{
            
            
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
//MARK: - UISearchResultsUpdating

extension ChapterViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    let category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    if category == "All" {
        filterContentForSearchTextWithoutCategory(searchBar.text!,category)
        
    }
    else {
        filterContentForSearchTextWithCategory(searchBar.text!,category)
        
    }
  }
}

//MARK: - UISearchBarDelegate

extension ChapterViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let category = searchBar.scopeButtonTitles![selectedScope]
        if category == "All" {
            filterContentForSearchTextWithoutCategory(searchBar.text!,category)
            
        }
        else {
            filterContentForSearchTextWithCategory(searchBar.text!,category)
            
        }
        
    }
}


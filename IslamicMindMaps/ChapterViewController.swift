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
    var myDbManager = DBManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var chapterTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chapterTableView.register(UINib(nibName: K.nib.ChaptersCell, bundle: nil), forCellReuseIdentifier: K.Cell.chaptersCell)
        
        chapterTableView.dataSource = self
        chapterTableView.delegate = self
        myDbManager.delegateChapters = self
        myDbManager.dataFetch()
        chapterTableView.keyboardDismissMode = .onDrag
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search chapters"
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
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
                if searchController.searchBar.textInputMode?.primaryLanguage == "ar"{
                    return doesCategoryMatch && chapter.arabicName.trim().contains(searchText.trim())
                }
                else {
                    return doesCategoryMatch && chapter.romanName.trim().lowercased().contains(searchText.lowercased().trim())
                }
            }
        }
        
        if (searchController.searchBar.text?.count == 0 || filteredChapterNamesArray.count > 0 ){
            
            chapterTableView.backgroundView = nil
            chapterTableView.separatorStyle = UITableViewCell.SeparatorStyle(rawValue: 1)!
            
        }
        if filteredChapterNamesArray.count == 0 {
            
            chapterTableView.backgroundView = noItemView
            chapterTableView.separatorStyle = .none
            
        }
        
        chapterTableView.reloadData()
    }
    
    func filterContentForSearchTextWithAllCategory(_ searchText: String,
                                                   _ category: String) {
        
        filteredChapterNamesArray = chapters.filter { (chapter: Chapter) -> Bool in
            
            if isSearchBarEmpty {
                return true
            } else {
                
                if searchController.searchBar.textInputMode?.primaryLanguage == "en-US" {
                    return  chapter.romanName.trim().lowercased().contains(searchText.trim().lowercased())
                }
                else {
                    return  chapter.arabicName.trim().contains(searchText.trim())
                }
            }
        }
        if (searchController.searchBar.text?.count == 0 || filteredChapterNamesArray.count > 0 ){
            
            chapterTableView.backgroundView = nil
            chapterTableView.separatorStyle = UITableViewCell.SeparatorStyle(rawValue: 1)!
            
        }
        if filteredChapterNamesArray.count == 0 {
            
            chapterTableView.backgroundView = noItemView
            chapterTableView.separatorStyle = .none
            
            
        }
        
        chapterTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = chapterTableView.indexPathForSelectedRow {
            tabBarController?.tabBar.isHidden = true
            let destinationVC = segue.destination as! VersesViewController
            destinationVC.chapter = chapters[indexPath.row]
        }
    }
}






//MARK: - Chapters Data Delegate

extension ChapterViewController:ChaptersDataDelegate {
    func didFailWithError(_ dbManager: DBManager, with error: String) {
        print(error)
    }
    
    
    func didUpdateChapters(_ dbManager: DBManager, with chaptersArray: [Chapter]) {
        chapters = chaptersArray
    }
}



//MARK: - UITableViewDelegate
extension ChapterViewController:UITableViewDataSource,UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        isFiltering ? filteredChapterNamesArray.count:chapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: K.Cell.chaptersCell, for: indexPath) as! ChaptersCell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.chaptersToVerses, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
//MARK: - UISearchResultsUpdating

extension ChapterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        if category == "All" {
            filterContentForSearchTextWithAllCategory(searchBar.text!,category)
            
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
            filterContentForSearchTextWithAllCategory(searchBar.text!,category)
            
        }
        else {
            filterContentForSearchTextWithCategory(searchBar.text!,category)
            
        }
        
    }
}



//MARK: - String Extention

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}



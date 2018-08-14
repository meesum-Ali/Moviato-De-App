//
//  MovieListViewController.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {

    var searchRequest: CustomRequest!
    var searchResponse: CustomResponse!
    
    private var movieList:[Results] = []
    private var currentPage = 1
    private var totalPages = 1
    private var shouldShowLoadingCell = false
    
    @IBOutlet weak var movieListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Search Results"
        //setting up pages counts and bool value if loading cell is to be shown
        currentPage = searchResponse?.page ?? currentPage
        totalPages = searchResponse?.total_pages ?? totalPages
        shouldShowLoadingCell = currentPage < totalPages
        //appending movie objects in movie list array
        for m in searchResponse?.results ?? [] {
            movieList.append(m)
        }
        movieListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//Mark:- Extension for Table View Delegate and Datasource Handling
extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = movieList.count
        return shouldShowLoadingCell ? count + 1 : count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if loading cell is true
        if isLoadingIndexPath(indexPath) {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? CustomMovieTableViewCell
        cell?.movieObject = movieList[indexPath.row]
        cell?.populateCell()
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform stuff on tapping a particular moie cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: UITableViewDelegate
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //will decide if to call network request and load next page
        guard isLoadingIndexPath(indexPath) else { return }
        fetchNextPage()
    }
    
}

//Mark:- other methods for pagination handling
extension MovieListViewController {
    
    //Method to check last cell path if its index path for loading cell
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        
        guard shouldShowLoadingCell else { return false }
        return indexPath.row == self.movieList.count
        
    }
    
    //Fetch next page
    private func fetchNextPage() {
        currentPage += 1
        loadMovies()
    }
    //method for loading movies
    private func loadMovies(refresh: Bool = false) {
        
        self.shouldShowLoadingCell = currentPage < totalPages
        searchRequest.page = String(currentPage)
        
        networkCall(searchRequest,
                    self,
                    true,
                    false) { (resp, isSuccess) in
            
            if isSuccess {
                
                for m in resp?.results ?? [] {
                    self.movieList.append(m)
                }
                
                self.movieListTableView.reloadData()
                
            }
        }
        
    }
}

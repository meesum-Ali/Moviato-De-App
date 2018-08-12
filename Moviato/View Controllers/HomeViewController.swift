//
//  ViewController.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var suggestionListTableView: UITableView!
    @IBOutlet weak var searckStackView: UIStackView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    //    let searchController = UISearchController(searchResultsController: nil)
    
    var sugestionsKeys: [String] = []
    var sugestionsObjects: [String:CustomResponse] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Moviato"
        // Setup the Search Controller
//        searchController.searchResultsUpdater = self
//        if #available(iOS 9.1, *) {
//            searchController.obscuresBackgroundDuringPresentation = false
//        } else {
//            // Fallback on earlier versions
//        }
        
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.searchBar.placeholder = "Search"
//        searchController.searchBar.isTranslucent = true
//
//        searchController.view.layoutIfNeeded()
        
        suggestionListTableView.tableFooterView = UIView()
        
//        callSearchApiRequestAndRouteToMovieList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        suggestionListTableView.reloadData()
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        callSearchApiRequestAndRouteToMovieList()
    }
    
    fileprivate func callSearchApiRequestAndRouteToMovieList() {
        let requestObj = CustomRequest()
        requestObj.query = searchTextField.text
        requestObj.page = "1"
        
        networkCall(requestObj, self, true) { (resp, isSuccess) in
            
            if isSuccess {
                
                self.sugestionsKeys.append(self.searchTextField.text!)
                self.sugestionsObjects[self.searchTextField.text!] = resp
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
                vc.searchResponse = resp
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//Mark:- Extension for Table View Delegate and Datasource Handling
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sugestionsKeys.count > 0 {
            tableView.restore()
        }
        else {
            tableView.setEmptyMessage("No Suggestion Available Yet")
        }
        
            return sugestionsKeys.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = sugestionsKeys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movieObj = sugestionsObjects[sugestionsKeys[indexPath.row]]
        let vc = storyboard?.instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
        vc.searchResponse = movieObj
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}


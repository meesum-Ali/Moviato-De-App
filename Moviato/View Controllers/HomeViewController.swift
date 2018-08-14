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
        
    var sugestionsKeys: [String] = []
    var sugestionsObjects: [String:CustomResponse] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        self.title = "Moviato"
        // Setting up the view
        searchButton.layer.cornerRadius = searchButton.frame.height/2.0
        suggestionListTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Clear text of search field and reloading suggestions if any
        searchTextField.text = ""
        suggestionListTableView.reloadData()
        
    }
    
    // action on tapping search button
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        searchTextField.resignFirstResponder()
        // Empty search field error handling
        if searchTextField.text == "" {
            showAlert(title: "Alert", msg: "Please type movie name then press search.", vc: self, completionHandler: {
                return
            })
            return
        }
        //calling network request for fetching initial list
        callSearchApiRequestAndRouteToMovieList()
    }
    
    fileprivate func callSearchApiRequestAndRouteToMovieList() {
        
        //creating request object
        let requestObj = CustomRequest()
        requestObj.query = searchTextField.text
        requestObj.page = "1"
        
        //network call from network class
        networkCall(requestObj, self, true) { (resp, isSuccess) in
            
            if isSuccess {
                
                //Empty list error handling
                if resp?.results == nil || (resp?.results?.count)! < 1 {
                    showAlert(title: "Alert", msg: "No result found", vc: self, completionHandler: {})
                    return
                }
                //appending keys and object for in memory persistance in order to show suggestions
                self.sugestionsKeys.append(self.searchTextField.text!)
                self.sugestionsObjects[self.searchTextField.text!] = resp
                
                //initiating Movie List View controller and pushing to the stack
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
                // Setting up properties required by VC to be presented
                vc.searchRequest = requestObj
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
            //Used extension of UITableview implemented in the end of this controller
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
        //If a cell if tapped from suggestions
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

// Empty table message and restoration
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


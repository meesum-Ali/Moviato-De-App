//
//  ViewController.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var movieListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        movieListTableView.tableFooterView = UIView()
        
        let requestObj = CustomRequest()
        requestObj.query = "Batman"
        requestObj.page = "1"
        
        networkCall(requestObj, self, true) { (resp, isSuccess) in
            
            if isSuccess {
                print(resp?.page ?? "not found")
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
}


//
//  RequestProgressIndicatiorView.swift
//  HblMobile_newDesign
//
//  Created by Adil Abbas on 5/8/18.
//  Copyright © 2018 Nargis Hameed. All rights reserved.
//

import UIKit

class RequestProgressIndicatiorView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var progContentView: UIView!
    @IBOutlet weak var headLbl: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var detailLbl: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        initSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    
    func  initSubviews() {

        let nib = UINib(nibName: "RequestProgressIndicatiorView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        self.backgroundColor = UIColorFromRGB(rgbValue: 0x000000,
                                              alphaValue: 0.7)
    }
    
}

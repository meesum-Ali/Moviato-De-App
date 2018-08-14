//  RequestProgressIndicatiorView.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//  Used an already developed progress view designed by me in another project not to be mention here :)

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

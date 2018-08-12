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
        self.setNewStyle()
    }
    
    //MARK:- Styles Method
    func setOldStyle() {
        self.view.backgroundColor = Color_Constants.popUpBackgroundColor_Black
        setLblStyle(lbls: [headLbl], style: .Value_Lbl_Gray_Bold)
        setLblStyle(lbls: [detailLbl], style: .Field_Lbl_Gray_Bold)
    }
    func setNewStyle() {
        self.view.backgroundColor = Color_Constants.popUpBackgroundColor_Green
        setLblStyle(lbls: [headLbl], style: .Value_Lbl_Green_Bold)
        setLblStyle(lbls: [detailLbl], style: .Field_Lbl_Green_Bold)
    }
    
}

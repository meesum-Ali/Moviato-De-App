//
//  ErrorPopupView.swift
//  HblMobile_newDesign
//
//  Created by Adil Abbas on 5/25/18.
//  Copyright © 2018 Nargis Hameed. All rights reserved.
//

import UIKit

class ErrorPopupView: UIView {

    @IBOutlet weak var textMsgTopConstraint: NSLayoutConstraint!
    @IBOutlet var view: UIView!
   
    @IBOutlet weak var popupContentView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var errorTxtLbl: UILabel!
    @IBOutlet weak var btnsStackView: UIStackView!
    @IBOutlet weak var okayBtn: UIButton!
    
    var completionCodeBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    func  initSubviews() {
        let nib = UINib(nibName: "ErrorPopupView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
       
        self.backgroundColor = UIColorFromRGB(rgbValue: 0x000000,
                                              alphaValue: 0.7)
        
    }
    
    @IBAction func okayBtnTapped(_ sender: UIButton) {
        
        self.removeFromSuperview()
         let _ = completionCodeBlock!()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
         let _ = completionCodeBlock!()
    }
    


    
}

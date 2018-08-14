//  ErrorPopupView.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//  Used an already developed error popup view designed by me in another project not to be mention here :)

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

//
//  CustomMovieTableViewCell.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//

import UIKit
import Kingfisher

class CustomMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var movieTitleLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var overviewLbl: UILabel!
    
    var movieObject: Results?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //populateCell()
    }

    /// Populates cell with provided movie object.
    func populateCell() {
        
        movieTitleLbl.text = movieObject?.title ?? "Title Not Available"
        releaseDateLbl.text = movieObject?.release_date ?? "Release Date Not Available"
        overviewLbl.text = movieObject?.overview ?? "Overview Not Available"
        
        let url = URL(string: "http://image.tmdb.org/t/p/w92\(movieObject?.poster_path ?? "")")
        
        bannerImageView.kf.setImage(with: url, placeholder: UIImage(named:"avatar"), options: nil, progressBlock: { (initial, final) in
            
        }) { (img, err, cacheType, ur) in
            
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

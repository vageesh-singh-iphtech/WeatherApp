//
//  WeatherCell2.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 25/03/25.
//

import UIKit

class WeatherCell2: UITableViewCell {
    
    
    @IBOutlet weak var Day: UILabel!
    
    
    @IBOutlet weak var lblImage: UIImageView!
    
    @IBOutlet weak var lblTempCell: UILabel!
    
    @IBOutlet weak var lnlTempCell2: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  AllLocationCustomCell.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 27/03/25.
//

import UIKit

class AllLocationCustomCell: UITableViewCell {
    
    
    @IBOutlet weak var cellView: UIView!
    
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lbltime: UILabel!
    
    @IBOutlet weak var lblDayType: UILabel!
    
    @IBOutlet weak var lblTemperature: UILabel!
    
    @IBOutlet weak var lnlDayData: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

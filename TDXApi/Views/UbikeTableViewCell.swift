//
//  UbikeTableViewCell.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/16.
//

import UIKit

class UbikeTableViewCell: UITableViewCell {
    
    @IBOutlet var cityImage: UIImageView!
    @IBOutlet var cityName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  StationDetailTableViewCell.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/17.
//

import UIKit

class StationDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var stationNameLabel: UILabel?
    @IBOutlet var bikeWithPowerLabel: UILabel?
    @IBOutlet var bikeWithoutPowerLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var lastUpdateTimeLabel: UILabel?
    
    var currentStationDetail: CurrentStationDetail = CurrentStationDetail(StationUID: "", ServiceStatus: 0, ServiceType: 0, AvailableRentBikes: 0, AvailableReturnBikes: 0, SrcUpdateTime: "", UpdateTime: "", AvailableRentBikesDetail: AvailableRentBike(GeneralBikes: 0, ElectricBikes: 0))

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

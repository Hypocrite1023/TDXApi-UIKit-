//
//  SettingViewController.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/25.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet var showStationDontHaveBikeToRent: UISwitch!
    @IBOutlet var showStationDontHaveSpaceToReturn: UISwitch!
//    let stationDetailTableViewController = StationDetailTableViewController()
    weak var switchValueChangeDelegate: SwitchValueDelegate?
    var showStationDontHaveBikeToRentIsOn: Bool?
    var showStationDontHaveSpaceToReturnIsOn: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showStationDontHaveBikeToRent.isOn = showStationDontHaveBikeToRentIsOn ?? false
        showStationDontHaveSpaceToReturn.isOn = showStationDontHaveSpaceToReturnIsOn ?? false
        showStationDontHaveBikeToRent.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        showStationDontHaveSpaceToReturn.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let dontShowNoBikeCanRentIsOn = self.showStationDontHaveBikeToRent.isOn
        let dontShowNoSpaceCanReturnIsOn = self.showStationDontHaveSpaceToReturn.isOn
        print(dontShowNoBikeCanRentIsOn, dontShowNoSpaceCanReturnIsOn)
        switchValueChangeDelegate?.switchValueDidChange(dontShowNoBikeCanRentIsOn: dontShowNoBikeCanRentIsOn, dontShowNoSpaceCanReturn: dontShowNoSpaceCanReturnIsOn)
    }

}

protocol SwitchValueDelegate: AnyObject {
    func switchValueDidChange(dontShowNoBikeCanRentIsOn: Bool, dontShowNoSpaceCanReturn: Bool)
}

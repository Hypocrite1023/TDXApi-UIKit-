//
//  UbikeStationViewController.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/16.
//

import UIKit

class UbikeStationViewController: UIViewController {
    
    var detail: UbikeTableViewDataModel?
    var token = Token()
    var detailManager = StationDetailManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Task {
            let _ = await token.getToken()
            if let city = detail?.cityName {
                try? await detailManager.getPublicBikeAvailabilityFor(city: city)
            }
        }
        navigationItem.title = detail?.cityName.rawValue
//        print(token.clientID, token.clientSecret)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func loadStationDetail() {
        
    }

}

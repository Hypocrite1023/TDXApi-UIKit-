//
//  UbikeStationViewController.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/16.
//

import UIKit

class UbikeStationViewController: UIViewController {
    
    @IBOutlet var cityName: UILabel?
    var detail: UbikeTableViewDataModel?
    var token = Token()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cityName?.text = detail?.cityName.rawValue
//        Task {
//            let token = await token.getToken()
//            print(token)
//        }
        print(token.clientID, token.clientSecret)
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

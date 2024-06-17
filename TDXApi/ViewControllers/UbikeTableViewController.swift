//
//  UbikeTableViewController.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/16.
//

import UIKit

class UbikeTableViewController: UITableViewController {
    
    var cities: [UbikeTableViewDataModel] = {
        var tmpArr: [UbikeTableViewDataModel] = []
        for city in CountyString.allCases {
            tmpArr.append(UbikeTableViewDataModel(cityName: city, cityImageSourceName: city.stringValue))
        }
        return tmpArr
    }()
    
    enum Sections: CaseIterable {
        case all
    }
    
    lazy var dataSource = returnDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.dataSource = dataSource
        var snapShot = NSDiffableDataSourceSnapshot<Sections, UbikeTableViewDataModel>()
        snapShot.appendSections(Sections.allCases)
        snapShot.appendItems(cities, toSection: .all)
        self.dataSource.apply(snapShot)
    }

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cities.count
    }
     */
    
    func returnDataSource() -> UITableViewDiffableDataSource<Sections, UbikeTableViewDataModel> {
        let dataSource = UITableViewDiffableDataSource<Sections, UbikeTableViewDataModel>(tableView: tableView, cellProvider: {
            (UITableView, IndexPath, UbikeTableViewDataModel) -> UbikeTableViewCell? in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ubikeCityCell", for: IndexPath) as? UbikeTableViewCell
            cell?.cityName.text = UbikeTableViewDataModel.cityName.rawValue
            cell?.cityImage.image = UIImage(named: UbikeTableViewDataModel.cityImageSourceName)
            return cell
            })
        return dataSource
    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        _ = UITableViewDiffableDataSource<Sections, UbikeTableViewDataModel>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ubikeCityCell", for: indexPath) as? UbikeTableViewCell
//            cell?.cityName.text = item.cityName
//            cell?.cityImage.image = UIImage(named: item.cityImageSourceName)
//            return cell
//        }
//        return UITableViewCell()
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showStationDetail" {
            if let selectIndex = tableView.indexPathForSelectedRow {
                if let stationDetailView = segue.destination as? StationDetailTableViewController {
                    stationDetailView.detail = self.cities[selectIndex.row]
                }
            }
            
        }
    }
    
    
    
}

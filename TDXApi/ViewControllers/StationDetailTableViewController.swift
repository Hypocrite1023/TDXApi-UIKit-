//
//  StationDetailTableViewController.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/17.
//

import UIKit
import CoreLocation

class StationDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stationData = filteredStationDetail[indexPath.row]
        if let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "stationMapView") as? StationMapViewViewController {
            destinationViewController.stationData = stationData
            navigationController?.pushViewController(destinationViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredStationDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationDetailCell") as! StationDetailTableViewCell
        let station = filteredStationDetail[indexPath.row]
        cell.stationNameLabel?.text = station.StationName.Zh_tw.description
        cell.bikeCanRent?.text = station.AvailableRentBikes?.description
        cell.backgroundColor = (station.AvailableRentBikes! > 5 ? UIColor.green : (station.AvailableRentBikes! > 3 ? UIColor.yellow : UIColor.red)).withAlphaComponent(0.3)
        cell.bikeCanReturn?.text = station.AvailableReturnBikes?.description
        cell.lastUpdateTimeLabel?.text = station.SrcUpdateTime
        cell.distanceLabel?.text = formatDistance(station.distance!)
        return cell
        
//        return UITableViewCell()
    }
    let numberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    func formatDistance(_ distance: Int) -> String {
        if distance >= 1000 {
            let distanceInKm = distance / 1000
            numberFormatter.maximumFractionDigits = 2
            return (numberFormatter.string(from: NSNumber(value: distanceInKm)) ?? "\(distanceInKm)") + " km"
        } else {
            numberFormatter.maximumFractionDigits = 0
            return (numberFormatter.string(from: NSNumber(value: distance)) ?? "\(distance)") + " m"
        }
    }
    
    
    var currentStationDetail: [mergeStationDetail] = []
    var filteredStationDetail: [mergeStationDetail] = []
//    lazy var dataSource = returnDetailDataSource()
    
    var detail: UbikeTableViewDataModel?
    var token = Token()
    var detailManager = StationDetailManager()
    var mergeResult = [String: mergeStationDetail]()
    
    
    var userCurrentLocation: CLLocation?
    
    @IBOutlet var tableView: UITableView!
    
    enum Sections: CaseIterable {
        case all
    }
    let locationManager = CLLocationManager()
    
    let stationNameSearchController = UISearchController(searchResultsController: nil)
    
    let settingViewController = SettingViewController()
    
    @IBAction func showSettingView() {
        if let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "settingViewController") as? SettingViewController {
            destinationViewController.switchValueChangeDelegate = self
            destinationViewController.showStationDontHaveBikeToRentIsOn = false
            destinationViewController.showStationDontHaveSpaceToReturnIsOn = false
            navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    let bikeLimit = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        Task {
            let _ = await token.getToken()
            if let city = detail?.cityName {
                if let result = try? await detailManager.getPublicBikeAvailabilityFor(city: city), let stationDetail = try? await detailManager.getPublicBikeRentalStationsDataFor(city: city) {
                    for eachDetail in stationDetail {
                        let tmpStruct = mergeStationDetail(StationUID: eachDetail.StationUID, StationName: eachDetail.StationName, StationPosition: eachDetail.StationPosition, StationAddress: eachDetail.StationAddress, BikesCapacity: eachDetail.BikesCapacity, ServiceType: eachDetail.ServiceType, SrcUpdateTime: nil, UpdateTime: nil, ServiceStatus: nil, AvailableRentBikes: nil, AvailableReturnBikes: nil, AvailableRentBikesDetail: nil)
                        mergeResult.updateValue(tmpStruct, forKey: eachDetail.StationUID)
                    }
                    for eachStationResult in result {
                        if var detailStruct = mergeResult[eachStationResult.StationUID] {
                            detailStruct.SrcUpdateTime = eachStationResult.SrcUpdateTime
                            detailStruct.UpdateTime = eachStationResult.UpdateTime
                            detailStruct.ServiceStatus = eachStationResult.ServiceStatus
                            detailStruct.AvailableRentBikes = eachStationResult.AvailableRentBikes
                            detailStruct.AvailableReturnBikes = eachStationResult.AvailableReturnBikes
                            detailStruct.AvailableRentBikesDetail = eachStationResult.AvailableRentBikesDetail
                            mergeResult.updateValue(detailStruct, forKey: detailStruct.StationUID)
                        }
                        
                    }
                    currentStationDetail = Array(mergeResult.values)
                    
                    for station in 0..<currentStationDetail.count {
                        if let userLocationNotNil = userCurrentLocation {
                            let userLocation = CLLocation(latitude: userLocationNotNil.coordinate.latitude, longitude: userLocationNotNil.coordinate.longitude)
                            let stationLocation = CLLocation(latitude: currentStationDetail[station].StationPosition.PositionLat, longitude: currentStationDetail[station].StationPosition.PositionLon)
                            let distanceBetweenStation = userLocation.distance(from: stationLocation)
                            
                            currentStationDetail[station].distance = Int(distanceBetweenStation)
                        } else {
                            currentStationDetail[station].distance = 0
                        }
                    }
                    currentStationDetail.sort { lhs, rhs in
                        lhs.distance! < rhs.distance!
                    }
                    filteredStationDetail = currentStationDetail
                    self.tableView.reloadData()
//                    print(currentStationDetail.first.debugDescription)
                }
            }
        }
        navigationItem.title = detail?.cityName.rawValue
//        tableView.dataSource = dataSource
//        var snapShot = NSDiffableDataSourceSnapshot<Sections, CurrentStationDetail>()
//        snapShot.appendSections(Sections.allCases)
//        snapShot.appendItems(currentStationDetail, toSection: .all)
//        self.dataSource.apply(snapShot, animatingDifferences: true)
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        stationNameSearchController.searchBar.placeholder = "搜尋站點"
        stationNameSearchController.obscuresBackgroundDuringPresentation = false
        stationNameSearchController.searchResultsUpdater = self
        navigationItem.searchController = stationNameSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        filteredStationDetail = currentStationDetail
        definesPresentationContext = true
        
        tableView.separatorStyle = .singleLine
        
        settingViewController.switchValueChangeDelegate = self
        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        }
//        tableView.register(StationDetailTableViewCell.self, forCellReuseIdentifier: "stationDetailCell")
    }
    
//    func returnDetailDataSource() -> UITableViewDiffableDataSource<Sections, CurrentStationDetail> {
//        let dataSource = UITableViewDiffableDataSource<Sections, CurrentStationDetail>(tableView: tableView) { tableView, indexPath, itemIdentifier in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "stationDetailCell") as? StationDetailTableViewCell
//            cell?.stationNameLabel.text = itemIdentifier.StationUID
//            cell?.bikeWithPowerLabel.text = itemIdentifier.AvailableRentBikesDetail.ElectricBikes.description
//            cell?.bikeWithoutPowerLabel.text = itemIdentifier.AvailableRentBikesDetail.GeneralBikes.description
//            cell?.lastUpdateTimeLabel.text = itemIdentifier.SrcUpdateTime
//            cell?.distanceLabel.text = "\(0.description) m"
//            return cell
//        }
//        return dataSource
//    }

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
     */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "showStationDetail" {
//            if let selectedIndex = tableView.indexPathForSelectedRow {
//                if let destination = segue.destination as? UbikeStationViewController {
//                    destination.detail = 
//                }
//            }
//            
//        }
//    }
    

}

extension StationDetailTableViewController: SwitchValueDelegate {
    
    func switchValueDidChange(dontShowNoBikeCanRentIsOn: Bool, dontShowNoSpaceCanReturn: Bool) {
        print("delegate", dontShowNoBikeCanRentIsOn, dontShowNoSpaceCanReturn)
        if dontShowNoBikeCanRentIsOn && dontShowNoSpaceCanReturn {
            filteredStationDetail = currentStationDetail.filter({ $0.AvailableRentBikes! > bikeLimit && $0.AvailableReturnBikes! > bikeLimit})
        } else if dontShowNoBikeCanRentIsOn && !dontShowNoSpaceCanReturn {
            filteredStationDetail = currentStationDetail.filter({ $0.AvailableRentBikes! > bikeLimit})
        } else if !dontShowNoBikeCanRentIsOn && dontShowNoSpaceCanReturn {
            filteredStationDetail = currentStationDetail.filter({ $0.AvailableReturnBikes! > bikeLimit})
        } else {
            filteredStationDetail = currentStationDetail
        }
        tableView.reloadData()
    }
    
    
}

extension StationDetailTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            print("Location services are not allowed")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location.coordinate.latitude, location.coordinate.longitude)
            userCurrentLocation = location
        }
        manager.stopUpdatingLocation()
    }
}

extension StationDetailTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        filterStationByStation(name: searchText)
    }
    
    func filterStationByStation(name searchText: String) {
        filteredStationDetail = searchText.isEmpty ? currentStationDetail : currentStationDetail.filter({ stationDetail in
            stationDetail.StationName.Zh_tw.contains(searchText)
        })
        tableView.reloadData()
    }
    
    
}

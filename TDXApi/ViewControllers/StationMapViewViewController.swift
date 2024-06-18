//
//  StationMapViewViewController.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/18.
//

import UIKit
import MapKit
import CoreLocation

class StationMapViewViewController: UIViewController {
    
    @IBOutlet var stationMapView: MKMapView!
    @IBOutlet var navigateButton: UIButton!
    @IBOutlet var segmentControl: UISegmentedControl!
    var routeLineColor: UIColor?
    @IBAction func navigateToStation(sender: UIButton) {
        
        var transportType: MKDirectionsTransportType?
        
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            transportType = .walking
            routeLineColor = .green
            break
        case 1:
            transportType = .automobile
            routeLineColor = .red
            break
        case 2:
            transportType = .walking
            routeLineColor = .blue
        default:
            transportType = .walking
            routeLineColor = .blue
            break
        }
//        let geocoder = CLGeocoder()
//        if let stationLat = stationData?.StationPosition.PositionLat, let stationLon = stationData?.StationPosition.PositionLon {
//            geocoder.reverseGeocodeLocation(CLLocation(latitude: stationLat, longitude: stationLon)) { placemarks, error in
//                if let error = error {
//                    print(error, "geocoder reverseGeocoderLocation error")
//                } else if let placemarks = placemarks, let placemark = placemarks.first {
//                    let directionRequest = MKDirections.Request()
//                    directionRequest.source = MKMapItem.forCurrentLocation()
//                    directionRequest.destination = MKMapItem(placemark: MKPlacemark(placemark: placemark))
//                    directionRequest.transportType = .walking
//                    
//                    let directions = MKDirections(request: directionRequest)
//                    directions.calculate { response, error in
//                        guard let response = response else {
//                            if let error = error {
//                                print(error)
//                            }
//                            return
//                        }
//                        
//                        let route = response.routes[0]
//                        self.stationMapView.addOverlay(route.polyline, level: .aboveRoads)
//                    }
//                }
//            }
//        }
        let geocoder = CLGeocoder()
        if let stationLat = stationData?.StationPosition.PositionLat, let stationLon = stationData?.StationPosition.PositionLon {
            let location = CLLocation(latitude: stationLat, longitude: stationLon)
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Geocoder error: \(error.localizedDescription)")
                } else if let placemarks = placemarks, let placemark = placemarks.first {
                    let directionRequest = MKDirections.Request()
                    directionRequest.source = MKMapItem.forCurrentLocation()
                    let destinationPlacemark = MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary: nil)
                    directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
                    directionRequest.transportType = transportType!
                    
                    let directions = MKDirections(request: directionRequest)
                    directions.calculate { response, error in
                        guard let response = response else {
                            if let error = error {
                                print("Directions error: \(error.localizedDescription)")
                            }
                            return
                        }
                        
                        let route = response.routes[0]
                        DispatchQueue.main.async {
                            self.stationMapView.removeOverlays(self.stationMapView.overlays)
                            self.stationMapView.addOverlay(route.polyline, level: .aboveRoads)
                            let rect = route.polyline.boundingMapRect
                            
//                            let annotation = MKAnnotationView()
//                            annotation.coordinate = MKCoordinateRegion(rect).center
//                            annotation.detailCalloutAccessoryView
                            
//                            self.stationMapView.addAnnotation(annotation)
                            
                            self.stationMapView.setRegion(MKCoordinateRegion(rect), animated: true)
                        }
                    }
                }
            }
        }
        navigateButton.isHidden = true
        segmentControl.isHidden = false
        
        
        
    }
    var stationData: mergeStationDetail?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.isHidden = true
        stationMapView.delegate = self

        // Do any additional setup after loading the view.
        stationMapView.showsUserLocation = true
        if let stationLat = stationData?.StationPosition.PositionLat, let stationLon = stationData?.StationPosition.PositionLon {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: stationLat, longitude: stationLon), latitudinalMeters: 500, longitudinalMeters: 500)
            stationMapView.region = region
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLon)
            stationMapView.addAnnotation(annotation)
        }
        
        segmentControl.addTarget(self, action: #selector(navigateToStation), for: .valueChanged)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension StationMapViewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = routeLineColor
        renderer.lineWidth = 4
        
        return renderer
    }
}

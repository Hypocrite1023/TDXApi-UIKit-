//
//  DistanceAnnotation.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/20.
//

import UIKit
import MapKit

class DistanceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var distance: Int
    
    init(coordinate: CLLocationCoordinate2D, distance: Int) {
        self.coordinate = coordinate
        self.distance = distance
    }

}

class DistanceAnnotationView: MKAnnotationView {
    private var distanceLabel: UILabel = UILabel()
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupDistanceLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDistanceLabel()
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDistanceLabel() {
        distanceLabel.text = (annotation as? DistanceAnnotation)?.distance.description
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.backgroundColor = .white.withAlphaComponent(0.5)
        distanceLabel.textColor = .black
        distanceLabel.textAlignment = .center
        distanceLabel.font = UIFont.systemFont(ofSize: 12)
        distanceLabel.layer.cornerRadius = 5
        distanceLabel.layer.masksToBounds = true
        distanceLabel.lineBreakMode = .byWordWrapping
        distanceLabel.numberOfLines = 1
        distanceLabel.sizeToFit()

        addSubview(distanceLabel)

        NSLayoutConstraint.activate([
            distanceLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            distanceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            distanceLabel.widthAnchor.constraint(equalToConstant: 50),
//            distanceLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let distanceAnnotation = annotation as? DistanceAnnotation else {
                return
            }
            print(distanceAnnotation.distance.description, "second")
            distanceLabel.text = convertSecondToMinuteOrAbove(inSecond: distanceAnnotation.distance)
        }
    }
    func convertSecondToMinuteOrAbove(inSecond second: Int) -> String {
        var sec = second
        var day = 0
        var hour = 0
        var minute = 0
        
        
        if sec >= 86400 {
            day = sec / 86400
            sec %= 86400
        }
        
        if sec >= 3600 {
            hour = sec / 3600
            sec %= 3600
        }
        
        if sec >= 60 {
            minute = sec / 60
            sec %= 60
        }
        
        
        return "估計路程:" + (day == 0 ? "" : "\(day)天") + (hour == 0 ? "" : "\(hour)小時") + (minute == 0 ? "" : "\(minute)分鐘") + (sec == 0 ? "" : "\(sec)秒")
        
    }
}

//
//  StationDetailDataModel.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/16.
//

import Foundation

struct StationDetail: Codable {
    
    let StationUID: String
    let StationName: StationName
    let StationPosition: Position
    let StationAddress: Address
    let BikesCapacity: Int
    let ServiceType: Int
    let SrcUpdateTime: String
    let UpdateTime: String
    
    enum CodingKeys: String, CodingKey {
        case StationUID = "StationUID"
        case StationName = "StationName"
        case StationPosition = "StationPosition"
        case StationAddress = "StationAddress"
        case BikesCapacity = "BikesCapacity"
        case ServiceType = "ServiceType"
        case SrcUpdateTime = "SrcUpdateTime"
        case UpdateTime = "UpdateTime"
    }
}

struct CurrentStationDetail: Codable, Hashable {
    
    let StationUID: String
//    let StationID : String
    let ServiceStatus : Int
    let ServiceType : Int
    let AvailableRentBikes : Int
    let AvailableReturnBikes : Int
    let SrcUpdateTime : String
    let UpdateTime : String
    let AvailableRentBikesDetail: AvailableRentBike
      
}

struct StationName: Codable {
    let Zh_tw: String
    let En: String
}
struct Position: Codable {
    let PositionLon: Double
    let PositionLat: Double
    let GeoHash: String
}
struct Address: Codable {
    let Zh_tw: String
    let En: String
}
struct AvailableRentBike: Codable, Hashable {
    let GeneralBikes: Int
    let ElectricBikes: Int
}

struct mergeStationDetail {
    // getPublicBikeRentalStationsDataFor()
    let StationUID: String
    let StationName: StationName
    let StationPosition: Position
    let StationAddress: Address
    let BikesCapacity: Int
    let ServiceType: Int
    
    // getPublicBikeAvailabilityFor()
    var SrcUpdateTime: String?
    var UpdateTime: String?
    var ServiceStatus : Int?
    var AvailableRentBikes : Int?
    var AvailableReturnBikes : Int?
    var AvailableRentBikesDetail: AvailableRentBike?
    
    var distance: Int?
}

class StationDetailManager {
    // https://tdx.transportdata.tw/api/basic/v2/Bike/Station/City/MiaoliCounty?%24format=JSON
    func getPublicBikeRentalStationsDataFor(city country: CountyString) async throws -> [StationDetail]? {
        let stationDetailApiURL = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Bike/Station/City/\(country.stringValue)?%24format=JSON")
        guard let apiUrl = stationDetailApiURL else {
            throw urlSessionError.urlError
        }
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "get"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: UserDefaultString.tokenKey)!)", forHTTPHeaderField: "authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let res = (response as? HTTPURLResponse)?.statusCode {
            guard (200...299).contains(res) else {
                throw urlSessionError.responseCodeError
            }
            let decoder = JSONDecoder()
            let result = try decoder.decode([StationDetail].self, from: data)
            print(result.first.debugDescription)
            return result
        }
        return nil
    }
    
    // https://tdx.transportdata.tw/api/basic/v2/Bike/Availability/City/MiaoliCounty?%24format=JSON
    func getPublicBikeAvailabilityFor(city country: CountyString) async throws -> [CurrentStationDetail]? {
        let stationDetailApiURL = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Bike/Availability/City/\(country.stringValue)?%24format=JSON")
        guard let apiURL = stationDetailApiURL else {
            throw urlSessionError.urlError
        }
        
        var request = URLRequest(url: apiURL)
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: UserDefaultString.tokenKey)!)", forHTTPHeaderField: "authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let res = (response as? HTTPURLResponse)?.statusCode {
            guard (200...299).contains(res) else {
                throw urlSessionError.responseCodeError
            }
            let decoder = JSONDecoder()
            let result = try decoder.decode([CurrentStationDetail].self, from: data)
            return result
        }
        return nil
    }
}

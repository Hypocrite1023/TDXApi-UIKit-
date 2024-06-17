//
//  DataModels.swift
//  TDXApi
//
//  Created by 邱翊均 on 2024/6/16.
//

import Foundation



struct readSecretFromConfig {
    static func secret() -> (String?, String?) {
        if let path = Bundle.main.path(forResource: "config", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    let id = json["clientID"]
                    let secret = json["clientSecret"]
                    return (id, secret)
                }
            } catch {
                print("Error reading config file: \(error.localizedDescription)")
            }
        }
        return (nil, nil)
    }
}

enum urlSessionError: Error {
    case responseError, responseCodeError, urlError
}

struct AuthResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct UserDefaultString {
    static let tokenExpireAt = "tokenExpireAt"
    static let tokenKey = "tokenKey"
}

class Token {
    let accessTokenURL = URL(string: "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token")!
    let (clientID, clientSecret) = readSecretFromConfig.secret()
//    let clientID = ""
//    let clientSecret = ""
    func getToken() async -> String? {
        if checkTokenAlive() { // token 還有效
            print("token from userdefault")
            return UserDefaults.standard.string(forKey: UserDefaultString.tokenKey)
        }
        else { // token 沒效,重新 get token
            Task {
                print("get new token")
                return try? await getNewToken()
            }
        }
        return nil
    }
    
    func getNewToken() async throws -> String? {
        var request = URLRequest(url: self.accessTokenURL)
        request.httpMethod = "post"
        request.httpBody = "grant_type=client_credentials&client_id=\(clientID!)&client_secret=\(clientSecret!)".data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let res = response as? HTTPURLResponse {
            guard (200...299).contains(res.statusCode) else {
                throw urlSessionError.responseCodeError
            }
            
            let decoder = JSONDecoder()
            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            let tokenExpierDate = Date.now.addingTimeInterval(TimeInterval(authResponse.expiresIn - 60))
            setTokenExpireDate(is: tokenExpierDate)
            setTokenToUserDefault(token: authResponse.accessToken)
            return authResponse.accessToken
        }
        else {
            throw urlSessionError.responseError
        }
    }
    
    func setTokenToUserDefault(token: String) {
        UserDefaults.standard.setValue(token, forKey: UserDefaultString.tokenKey)
    }
    
    func setTokenExpireDate(is date: Date) {
        UserDefaults.standard.setValue(date, forKey: UserDefaultString.tokenExpireAt)
    }
    
    func checkTokenAlive() -> Bool {
        if let tokenExpireDate = UserDefaults.standard.object(forKey: UserDefaultString.tokenExpireAt) as? Date {
            return Date.now < tokenExpireDate
        }
        else {
            return false
        }
    }
}

enum CountyString: String, CaseIterable {
    case 臺北市, 新北市, 桃園市, 新竹縣, 新竹市, 苗栗縣, 臺中市, 嘉義市, 臺南市, 高雄市, 屏東縣
    var stringInChinese: String {
        return self.rawValue
    }
    var stringValue: String {
        switch self {
        case .臺北市:
            return "Taipei"
        case .新北市:
            return "NewTaiPei"
        case .桃園市:
            return "Taoyuan"
        case .新竹縣:
            return "HsinchuCounty"
        case .新竹市:
            return "Hsinchu"
        case .苗栗縣:
            return "MiaoliCounty"
        case .臺中市:
            return "Taichung"
        case .嘉義市:
            return "Chiayi"
        case .臺南市:
            return "Tainan"
        case .高雄市:
            return "Kaohsiung"
        case .屏東縣:
            return "PingtungCounty"
        }
    }
}

//https://tdx.transportdata.tw/api/basic/v2/Bike/Station/City/MiaoliCounty?%24format=JSON
struct UbikeTableViewDataModel: Hashable {
    let cityName: CountyString
    let cityImageSourceName: String
    lazy var requestURL = "https://tdx.transportdata.tw/api/basic/v2/Bike/Station/City/\(cityName.stringValue)?%24format=JSON"
}

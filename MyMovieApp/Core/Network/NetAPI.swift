//
//  NetAPI.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/16.
//


import Moya
import Foundation
import Alamofire
import RxSwift

enum NetAPI{
    case getHomeMovies
    case getMovieDetail(id : String)
    
}


extension NetAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: Const.BASE_URL)!
    }
    
    var path: String {
        switch self {
        case .getHomeMovies:
            return "/home/movie"
            
        case .getMovieDetail(let id):
            return "/details/movie/\(id)"

        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters : [String: Any] {
        switch self {
        case .getHomeMovies:
            return [:]
            
        case .getMovieDetail:
            return [:]

        }
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [
            "Authorization": "Bearer \(Const.ACCESS_TOKEN)",
            "Accept": "application/json"]
    }
    
    var sampleData: Data {
        
        switch self {
        case .getHomeMovies:
            return loadJSON("home_movies")
        case .getMovieDetail:
            return Data()
            
        }
    }
    
    func loadJSON(_ filename: String) -> Data {
            guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
                fatalError("File \(filename).json not found in bundle")
            }
            do {
                return try Data(contentsOf: url)
            } catch {
                fatalError("Failed to load \(filename).json: \(error)")
            }
        }
    
}


class DefaultAlamofireManager: Alamofire.Session, @unchecked Sendable {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.Session.default.session.configuration.httpAdditionalHeaders
        configuration.timeoutIntervalForRequest = 20 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

//let netApi = MoyaProvider<NetAPI>(plugins: [NetworkLoggerPlugin()])
let netApi = MoyaProvider<NetAPI>(session: DefaultAlamofireManager.sharedManager,plugins: [NetworkLoggerPlugin()])

let netStubApi = MoyaProvider<NetAPI>(stubClosure: MoyaProvider.immediatelyStub)

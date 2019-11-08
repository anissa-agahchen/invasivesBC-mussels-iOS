//
//  RemoteAPI.swift
//  FoodAnytime
//
//  Created by Pushan Mitra on 21/09/18.
//  Copyright © 2018 Pushan Mitra. All rights reserved.
//

import Foundation
import Alamofire

protocol JSONCodable {
    func json() -> Data
}

typealias JSONMap = Dictionary<String, Any>
typealias JSONArray = Array<Any>

extension String: JSONCodable {
    func json() -> Data {
        return self.data(using: .utf8) ?? Data()
    }
    
}

extension RemoteAPI {
    class func api() -> Self {
        return self.init(url: self.apiURL())
    }
}

struct VoidResponse: Codable {
    var status: String = "Success"
    var data: Data?
}

typealias PromiseVoidResp = Promise<VoidResponse>
typealias APIMethod = HTTPMethod

class RemoteAPI<R>: ExpressibleByStringLiteral {
    typealias Response = R
    typealias StringLiteralType = String
    
    /*class func api() -> self {
        return self.init(url: self.apiURL())
    }*/
    
    class func apiURL() -> String {
        return ""
    }
    
    
    var argMap: [String : String] = [:] {
        didSet {
            self._createURL()
        }
    }
    
    func body(method: APIMethod) -> JSONCodable {
        return ""
    }
    
    var isValid: Bool {
        return !self._url.isEmpty && URL(string: self._url) != nil
    }
    
    var token: String {
        return "";
    }
    
    
    var headers: RequestHeader  {
        return ["Content-Type" : "application/json","Authorization": self.token ]
    }
    internal var _url: String = ""
    internal var _unformattedURL: String = ""
    internal var _promise: Promise<Data>? = nil
    required init(url: String) {
        _url = url
        _unformattedURL = url
    }
    
    convenience required init(stringLiteral value: RemoteAPI.StringLiteralType) {
        self.init(url: value)
    }
    
    // Subclass must override this
    func processData(data: Data, more: Any?) -> (Response?, Any?) {
        return (nil, more)
    }
    
    
    func _invokeAPI(_ method: APIMethod) -> Promise<R>? {
        return Promise<Response>({ (resolve, reject) in
            if !isValid {
                InfoLog("Invalid URL : \(self._url)")
                DispatchQueue.main.async {
                    let message = "Invalid url: \(self._url)"
                    let error = AppError(code: ApplicationInvalidURLError, description: message, userInfo: nil)
                    reject(error, nil)
                }
                return
            }
            switch method {
            case .get:
                self._promise = RemoteAPIManager.default.get(self._url, self.headers)
            case .post:
                self._promise = RemoteAPIManager.default.post(self._url, body: self.body(method: method).json(), headers)
            case .put:
                self._promise = RemoteAPIManager.default.put(self._url, body: self.body(method: method).json(), headers)
            default:
                self._promise = RemoteAPIManager.default.api(self._url, body: self.body(method: method).json(), method: method, headers)
            }
            

            // Success case
            self._promise?.then({ (info, _) in
                do {
                    // Process req.
                    let p = self.processData(data: info, more: nil)
                    if let resp: Response = p.0 {
                        resolve(resp, nil)
                    } else {
                        throw AppError(description: "Unable to process json data")
                    }
                } catch (let excp) {
                    
                    if R.self == VoidResponse.self {
                        InfoLog("Void Response pattern: ignoring exception")
                        var voidResp = VoidResponse()
                        voidResp.data = info
                        let obj: R = voidResp as! R
                        resolve(obj, nil)
                    } else {
                        InfoLog("JSON Parsing Fail")
                        InfoLog("Reason: \(excp)")
                        InfoLog("Des: \(excp.localizedDescription): \((excp as NSError).code)")
                        let error: Error = AppError(code: ApplicationJSONParsingError, description:ApplicationJSONParsingErrorMessage , userInfo: nil)
                        reject(error, info)
                    }
                    
                }
            })
            
            
            // Fail Case
            self._promise?.error({ (error, _) in
                reject(error, nil)
            })
        })
    }
    
    func get() -> Promise<Response>? {
        return self._invokeAPI(.get)
    }
    
    func post() -> Promise<Response>? {
        return self._invokeAPI(.post)
    }
    
    func delete() -> Promise<Response>? {
        return self._invokeAPI(.delete)
    }
    
    func put() -> Promise<Response>? {
        return self._invokeAPI(.put)
    }
    
    func _createURL() {
        var url: String = self._unformattedURL
        let finalArgMap = self.willCreateURL(from: self.argMap)
        for (key,val) in finalArgMap {
            url = url.replacingOccurrences(of: key, with: val)
        }
        self._url = url
    }
    
    func willCreateURL(from argument: [String : String]) -> [String : String] {
        return argument
    }
    
    
}


extension RemoteAPI where R == JSONMap {
    func processData(data: Data, more: Any?) -> (JSONMap?, Any?) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONMap
            return (json, more)
        } catch let excp {
            InfoLog("JSON Parsing Fail")
            InfoLog("Reason: \(excp)")
            InfoLog("Des: \(excp.localizedDescription): \((excp as NSError).code)")
            return (nil, more)
        }
        
    }
}

extension RemoteAPI where R == JSONArray {
    func processData(data: Data, more: Any?) -> (JSONArray?, Any?) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONArray
            return (json, more)
        } catch let excp {
            InfoLog("JSON Parsing Fail")
            InfoLog("Reason: \(excp)")
            InfoLog("Des: \(excp.localizedDescription): \((excp as NSError).code)")
            return (nil, more)
        }
        
    }
}

extension RemoteAPI where R == Data {
    func processData(data: Data, more: Any?) -> (Data?, Any?) {
        return (data, more)
    }
}

class RemoteCodableAPI<R: Codable>: RemoteAPI<R> {
    override func processData(data: Data, more: Any?) -> (R?, Any?) {
        do {
            let decoder = JSONDecoder()
            let decodedStore: R = try decoder.decode(R.self, from: data)
            return (decodedStore, more)
        } catch let excp {
            InfoLog("JSON Parsing Fail")
            InfoLog("Reason: \(excp)")
            InfoLog("Des: \(excp.localizedDescription): \((excp as NSError).code)")
            return (nil, more)
        }
    }
}





extension RemoteAPI: CustomStringConvertible {
    var description: String {
        return _url
    }
    
}

extension RemoteAPI: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self._url) else { throw AFError.invalidURL(url: self.description) }
        return url
    }
}



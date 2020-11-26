//
//  URLRequest.swift
//  Commute
//
//  Created by Darren Jones on 09/10/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import Foundation

public
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}

public
extension URLRequest {
    
    /**
     A custom init that takes the headers and body as parameters. Converts body to JSON and sets the `httpMethod` to `POST`
     - Parameters:
        - url: The URL of the request
        - headers: A complete set of headers for the request
        - postBody: A `Dictionary` of data to send with the request
        - json: Encode the payload as JSON or just key:value pairs. Default is JSON
        - timeout: `TimeInterval` that defaults to 60 seconds
        - httpMethod: `HTTPMethod` eg. `.POST` `.GET` `.PUT` defaults to `.POST`
     - Returns: A `URLRequest` if the JSON creating was succesful, otherwise nil
     */
    init?(url:URL, headers:[String:String], postBody:[String:Any], json:Bool = true, timeout:TimeInterval = 60.0, httpMethod:HTTPMethod = HTTPMethod.POST) {
        
        self.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        self.allHTTPHeaderFields = headers
        
        if json == true
        {
            // Convert the body Dictionary to JSON
            guard let httpBody = try? JSONSerialization.data(withJSONObject: postBody, options: []) else {
                return nil
            }
//            print(String(data: httpBody, encoding: .utf8)!)
            self.httpBody = httpBody
        }
        else
        {
            // Convert the parameters Dictionary to URLQueryItem's to append to the URL
            var components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = postBody.compactMapValues({ $0 as? String }).map { (key, value) in
                    URLQueryItem(name: key, value: value)
            }
            self.httpBody = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)
        }
        
        self.httpMethod = httpMethod.rawValue
    }
    
    /**
     A custom init that takes the headers and body string as parameters. Sends the body as `String` and sets the `httpMethod` to `POST`
     - Parameters:
        - url: The URL of the request
        - headers: A complete set of headers for the request
        - postString: A `String` to send with the request
        - timeout: `TimeInterval` that defaults to 60 seconds
        - httpMethod: `HTTPMethod` eg. `.POST` `.GET` `.PUT` defaults to `.POST`
     - Returns: A `URLRequest` if the JSON creating was succesful, otherwise nil
     */
    init?(url:URL, headers:[String:String], postString:String, timeout:TimeInterval = 60.0, httpMethod:HTTPMethod = .POST) {
        
        self.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        self.allHTTPHeaderFields = headers
        
        // Convert the body String to Data
        let httpBody = postString.data(using: .utf8)
        self.httpBody = httpBody
        
        self.httpMethod = httpMethod.rawValue
    }
    
    /**
     A custom init that takes the headers and body as parameters. Converts body to URLParams and sets the `httpMethod` to `GET`
     - Parameters:
        - url: The URL of the request
        - headers: A complete set of headers for the request
        - getBody: A `Dictionary` of data to send with the request
        - timeout: `TimeInterval` that defaults to 60 seconds
     - Returns: A `URLRequest` if the JSON creating was succesful, otherwise nil
     */
    init?(url:URL, headers:[String:String], parameters:[String:String], timeout:TimeInterval = 60.0) {
        
        // Convert the parameters Dictionary to URLQueryItem's to append to the URL
        var components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//        print(components.url!)
        
        self.init(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        self.allHTTPHeaderFields = headers
        
        self.httpMethod = HTTPMethod.GET.rawValue
    }
}

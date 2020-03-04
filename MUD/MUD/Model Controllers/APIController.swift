//
//  APIController.swift
//  MUD
//
//  Created by Jordan Christensen on 3/3/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case encodingError
    case responseError
    case noData
    case badDecode
    case noToken
    case otherError(Error)
}

import Foundation

class APIController {
    var key: String?
    let baseURL = URL(string: "https://placed-mud.herokuapp.com/api/")!
    
    func login(user: UserLogin, completion: @escaping (NetworkError?) -> Void) {
        let url = baseURL.appendingPathComponent("login")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let userData = try JSONEncoder().encode(user)
            request.httpBody = userData
        } catch {
            NSLog("Error encoding user: \(error)")
            completion(.encodingError)
            return
        }
        
        
    }
    
    func register(user: UserRegister, completion: @escaping (NetworkError?) -> Void) {
        let url = baseURL.appendingPathComponent("registration")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let userData = try JSONEncoder().encode(user)
            request.httpBody = userData
        } catch {
            NSLog("Error encoding user: \(error)")
            completion(.encodingError)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.responseError)
                return
            }
            
            if let error = error {
                NSLog("\(#file):L\(#line): Error creating user on server inside \(#function): \(error)")
                completion(.otherError(error))
                return
            }
            
            guard let data = data else {
                NSLog("\(#file):L\(#line): No data returned from request inside \(#function)")
                completion(.noData)
                return
            }
            
            do {
                self.key = try JSONDecoder().decode(String.self, from: data)
                completion(nil)
            } catch {
                NSLog("\(#file):L\(#line): Configuration failed inside \(#function) with error: \(error)")
                completion(.badDecode)
            }
        }.resume()
    }
}

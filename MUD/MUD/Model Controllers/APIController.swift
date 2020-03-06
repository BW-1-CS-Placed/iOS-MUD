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
    var key: String? = "ae16e26fbb4f23d60124ef81c479c19d9250fa4f"
    let baseURL = URL(string: "https://placed-mud.herokuapp.com/api/")!
    
    func login(user: UserLogin, completion: @escaping (NetworkError?) -> Void) {
        let url = baseURL.appendingPathComponent("login")
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let userData = try JSONEncoder().encode(user)
            request.httpBody = userData
        } catch {
            NSLog("Error encoding user: \(error)")
            completion(.encodingError)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(String(data: data!, encoding: .utf8)!)
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                if let error = error {
                    print(error)
                }
                print(response.statusCode)
//                completion(.responseError)
//                return
            }
            
            if let error = error {
                NSLog("\(#file):L\(#line): Error fetching user from server in function \(#function): \(error)")
                completion(.otherError(error))
                return
            }
            
            guard let data = data else {
                NSLog("\(#file):L\(#line): No data returned from request in function \(#function)")
                completion(.noData)
                return
            }
            
            do {
                self.key = try JSONDecoder().decode(String.self, from: data)
                completion(nil)
            } catch {
                NSLog("\(#file):L\(#line): Configuration failed in function \(#function) with error: \(error)")
                completion(.badDecode)
            }
        }.resume()
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                if let error = error {
                    print(error)
                }
                print(response.statusCode)
//                completion(.responseError)
//                return
            }
            
            if let error = error {
                NSLog("\(#file):L\(#line): Error creating user on server in function \(#function): \(error)")
                completion(.otherError(error))
                return
            }
            
            guard let data = data else {
                NSLog("\(#file):L\(#line): No data returned from request in function \(#function)")
                completion(.noData)
                return
            }
            
            do {
                self.key = try JSONDecoder().decode(String.self, from: data)
                completion(nil)
            } catch {
                NSLog("\(#file):L\(#line): Configuration failed in function \(#function) with error: \(error)")
                completion(.badDecode)
            }
        }.resume()
    }
    
    func fetchRooms(completion: @escaping (Result<[Room], NetworkError>) -> Void) {
        guard let token = key else { completion(.failure(.noToken)); return }
        let url = baseURL.appendingPathComponent("dung")
            .appendingPathComponent("rooms")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                if let error = error {
                    print(error)
                }
                
                print(response.statusCode)
                completion(.failure(.responseError))
                return
            }
            
            if let error = error {
                NSLog("\(#file):L\(#line): Error creating user on server in function \(#function): \(error)")
                completion(.failure(.otherError(error)))
                return
            }
            
            guard let data = data else {
                NSLog("\(#file):L\(#line): No data returned from request in function \(#function)")
                completion(.failure(.noData))
                return
            }
            
            do {
                let dict = try JSONDecoder().decode([String: [Room]].self, from: data)
                if let rooms = dict.values.first {
                    completion(.success(rooms))
                } else {
                    completion(.failure(.badDecode))
                }
            } catch {
                NSLog("\(#file):L\(#line): Configuration failed in function \(#function) with error: \(error)")
                completion(.failure(.badDecode))
            }
        }.resume()
    }
    
    func fetchPlayerLocation(completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let token = key else { completion(.failure(.noToken)); return }
        let url = baseURL.appendingPathComponent("dung")
            .appendingPathComponent("init")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                if let error = error {
                    print(error)
                }
                
                print(response.statusCode)
                completion(.failure(.responseError))
                return
            }
            
            if let error = error {
                NSLog("\(#file):L\(#line): Error creating user on server in function \(#function): \(error)")
                completion(.failure(.otherError(error)))
                return
            }
            
            guard let data = data else {
                NSLog("\(#file):L\(#line): No data returned from request in function \(#function)")
                completion(.failure(.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(LocationResult.self, from: data)
                if let roomName = result.title, !roomName.isEmpty {
                    completion(.success(roomName))
                }
            } catch {
                NSLog("\(#file):L\(#line): Configuration failed in function \(#function) with error: \(error)")
                completion(.failure(.badDecode))
            }
        }.resume()
    }
    
    func move(_ direction: Direction, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let token = key else { completion(.failure(.noToken)); return }
        let url = baseURL.appendingPathComponent("dung")
                         .appendingPathComponent("move")
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(Cardinal(direction: direction.rawValue))
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user: \(error)")
            completion(.failure(.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                if let error = error {
                    print(error)
                }
                print(response.statusCode)
                completion(.failure(.responseError))
                return
            }
            
            if let error = error {
                NSLog("\(#file):L\(#line): Error creating user on server in function \(#function): \(error)")
                completion(.failure(.otherError(error)))
                return
            }
            
            guard let data = data else {
                NSLog("\(#file):L\(#line): No data returned from request in function \(#function)")
                completion(.failure(.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MoveResult.self, from: data)
                if let errorMessage = result.errorMessage, !errorMessage.isEmpty {
                    let error = NSError(domain: "com.mazjap.customError", code: 5856, userInfo: [ NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(.otherError(error)))
                } else if let roomName = result.title, !roomName.isEmpty {
                    completion(.success(roomName))
                }
            } catch {
                NSLog("\(#file):L\(#line): Configuration failed in function \(#function) with error: \(error)")
                completion(.failure(.badDecode))
            }
        }.resume()
    }
}

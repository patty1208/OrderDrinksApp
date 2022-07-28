//
//  MenuController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/23.
//

import Foundation
import UIKit

public let apiKey = "keyezMmClHKWxeYFA"

class MenuController {
    static let shared = MenuController()
    let baseURL = URL(string: "https://api.airtable.com/v0/appjeZuwHlxzgniTq/")!
    var menuResponse = MenuResponse.init(records: [MenuResponse.Record]())
    var orderResponse = OrderResponse.init(records: [OrderResponse.Record]())
    var categoryByMenu = ["冬季限定","原葉鮮萃茶", "鮮萃茶拿鐵", "鮮調果茶", "果然系列", "夏季限定", "奶茶 / 特調"]

    // MARK: - GET MENU
    func fetchMenuRecords(completion: @escaping (Result<[MenuResponse.Record], Error>) -> Void) {
        let baseMenuURL = baseURL.appendingPathComponent("Menu")
        guard let components = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true),
              let menuURL = components.url else { return }
        
        var request = URLRequest(url: menuURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    print("Fetch Menu Success")
                    
                    // 檢查資料
    //                    print("check get menu:")
    //                    data.prettyPrintedJSONString()
                    
                    let jsonDecoder = JSONDecoder()
                    let menuResponse = try jsonDecoder.decode(MenuResponse.self, from: data)
                    completion(.success(menuResponse.records))
                    
                } catch {
                    print("Fetch Menu Failed")
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - GET Order
    func fetchOrderRecords(completion: @escaping (Result<[OrderResponse.Record],Error>) -> Void) {
        let orderURL = baseURL.appendingPathComponent("Order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true),
              let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    print("Fetch Order Success")
                    
                    // 檢查資料
    //                    print("check get order:")
    //                    data.prettyPrintedJSONString()
                    
                    let jsonDecoder = JSONDecoder()
                    let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
                    completion(.success(orderResponse.records))
                } catch {
                    print("Fetch Order Failed")
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - POST Order
    func postOrder(orderData: Order, completion: @escaping (Result<[OrderResponse.Record],Error>) -> Void) {
        let orderURL = baseURL.appendingPathComponent("Order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true),
              let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let orderRecord = OrderResponse.Record(id: nil, fields: orderData, createdTime: nil)
        let orderResponse = OrderResponse(records: [orderRecord])
        let data = try? jsonEncoder.encode(orderResponse)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    
                    // 檢查上傳的資料
                    print("check create order data:")
                    data.prettyPrintedJSONString()
                    
                    let jsonDecoder = JSONDecoder()
                    let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
                    completion(.success(orderResponse.records))
                } catch {
                    print("post Order failure:\(error)")
                    completion(.failure(error))
                }
            } else if let error = error {
                print("postOrder failure:\(error)")
                
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - DELETE Order
    func deleteOrder(orderID: String, completion: @escaping(Result<String,Error>) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        guard var components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        components.queryItems = [URLQueryItem(name: "records[]", value: orderID)]
        guard let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with:request) { (data,response,error) in
            if let response = response as? HTTPURLResponse,
               let data = data,
               response.statusCode == 200,
               error == nil {
                // 檢查刪除的資料
                print("DeleteOrder success:")
                data.prettyPrintedJSONString()
                guard let content = String(data: data, encoding: .utf8) else { return }
                completion(.success(content))
            } else if let error = error {
                print("delete Order failure: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - PATCH Order
    func updateOrder(orderData: OrderResponse, completion: @escaping (Result<String, Error>) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true),
              let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(orderData)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                //                    let jsonDecoder = JSONDecoder()
                //                    let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
                
                // 檢查更新資料
                print("check update order:")
                data.prettyPrintedJSONString()
                guard let content = String(data:data,encoding: .utf8) else { return }
    //                print("update Order Success: \n\(content)")
                completion(.success(content))
            } else if let error = error {
                print("update Order Failure: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}



extension String{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension Data {
    func prettyPrintedJSONString() {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to read JSON Object.")
                return
            }
        print(prettyJSONString,"\n")
    }
}


//
//  JSO.swift
//
//  Created by Morten Just on 7/28/22.
//

import Foundation


/**
 Light-weight Axios-like JSON helpers.
 
 Simple call
 ```
 let response:ReturnType = try await JSO.post(
         url:url,
         body:encodableBody)
 ```
 
 With bearer
 ```
 let response:ReturnType = try await JSO.post(
    url:url,
    body:encodableBody,
    bearerToken:t)
```
 
 You can also specify the return type explicitly
 ```
 let response = try await JSO<ReturnType>.post(...
 ```
 
 */
public struct JSO<R:Decodable> {
    /// Post a JSON payload and get one back. Optional bearer token is added to Authorization header.
    static func post<B:Encodable>(url:URL, body:B, bearerToken:String?) async throws -> R   {
        
        // prep
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        if let bearerToken = bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        // request
        do {
            let ( data,_ ) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(R.self, from: data)
            return response
        }
    }
    
    // Get a JSON response from a GET request
    static func get(url:URL) async throws -> R {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        do {
            let(data,_) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(R.self, from: data)
            return response
        }
    }
}




// data task stuff

extension JSO {
    
    // HT John Sundell
    @available(macOS, deprecated: 12.0, message: "Just a reminder to replace this function with Apple's version, released in 12")
    static func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?
        let onCancel = { dataTask?.cancel() }

        return try await withTaskCancellationHandler(
            handler: {
                onCancel()
            },
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }
                        continuation.resume(returning: (data, response))
                    }
                    dataTask?.resume()
                }
            }
        )
    }
}


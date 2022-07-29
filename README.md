# JSO

 Light-weight Axios-like JSON helpers for Swift.
 
 ## Usage 
 
 Simple call
 
 ```swift
 let response:ReturnType = try await JSO.post(
         url:url,
         body:encodableBody)
 ```
 
 With bearer
 
 ```swift
 let response:ReturnType = try await JSO.post(
    url:url,
    body:encodableBody,
    bearerToken:t)
```
 
 ## Explicit return type 
 In the examples above, the return type is inferred. You can also specify the return type explicitly:
 
 ```swift
 let response = try await JSO<ReturnType>.post(...
 ```
 
 

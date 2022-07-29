import XCTest
@testable import JSO

final class JSOTests: XCTestCase {
    
    func testGET() async throws {
        struct TestResponse : Codable { let name:String; let city:String }
        
        let endpoint = URL(string: "http://echo.jsontest.com/name/morten/city/zurich")!
        
        let response:TestResponse = try await JSO.get(url: endpoint)
        XCTAssertEqual(response.name, "morten")
        XCTAssertEqual(response.city, "zurich")
    }
    
    func testHeaders() async throws {
        struct TestHeaders : Decodable { let Accept:String; let Authorization:String }
        struct Payload : Codable { let name:String }
        
        let url = URL(string: "http://headers.jsontest.com/")!
        let token = "klasdlfjkj3908ljkvxzclkxdzj;"
        
        let response:TestHeaders = try await JSO.post(url: url, body: Payload(name: "Morten"), bearerToken: token)
        XCTAssertEqual(response.Authorization, "Bearer \(token)")
        XCTAssertEqual(response.Accept, "application/json; charset=utf-8")
    }
}

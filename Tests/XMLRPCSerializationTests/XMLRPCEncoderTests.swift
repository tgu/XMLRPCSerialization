import XCTest
@testable import XMLRPCSerialization

class XMLRPCEncoderTests: XCTestCase {
    
    func testSimpleEncode() throws {
        let encoder = XMLRPCEncoder()
        let obj = SimpleTest()
        
        let data = try encoder.encode(obj, autoWrappingStructures: false)
        let readable = data.xmlString
        
        XCTAssertEqual(readable, xmlHeader + "<methodResponse><params><param><value><string>a</string></value></param><param><value><i4>5</i4></value></param><param><value><struct><member><name>c</name><value><string>d</string></value></member></struct></value></param></params></methodResponse>")
    }
    
    func testWrappingEncode() throws {
        let encoder = XMLRPCEncoder()
        let obj = WrappingTest()
        let data = try encoder.encode(obj, autoWrappingStructures: true)
        
        let outPrefix = xmlHeader + "<methodResponse><params><param><value><struct>"
        let possibleOrderings = [[0,1,2], [0,2,1], [1,0,2], [1,2,0], [2,0,1], [2,1,0]]
        let items = [
            "<member><name>a</name><value><string>a</string></value></member>",
            "<member><name>b</name><value><string>b</string></value></member>",
            "<member><name>c</name><value><struct><member><name>c</name><value><string>d</string></value></member></struct></value></member>",
        ]
        let outSuffix = "</struct></value></param></params></methodResponse>"
        let possibleOutputs = possibleOrderings.map { (o: [Int]) in outPrefix + items[o[0]] + items[o[1]] + items[o[2]] + outSuffix }
        
        XCTAssertNotNil(possibleOutputs.index { $0.xmlData == data }, "One of the inputs should match")
    }
    
    func testMethodCallEncode() throws {
        let encoder = XMLRPCEncoder()
        let obj = WrappingTestRequest()
        let data = try encoder.encode(obj, autoWrappingStructures: true)
        
        let outPrefix = xmlHeader + "<methodCall><methodName>test.method</methodName><params><param><value><struct>"
        let possibleOrderings = [[0,1,2], [0,2,1], [1,0,2], [1,2,0], [2,0,1], [2,1,0]]
        let items = [
            "<member><name>a</name><value><string>a</string></value></member>",
            "<member><name>b</name><value><string>b</string></value></member>",
            "<member><name>c</name><value><struct><member><name>c</name><value><string>d</string></value></member></struct></value></member>",
        ]
        let outSuffix = "</struct></value></param></params></methodCall>"
        let possibleOutputs = possibleOrderings.map { (o: [Int]) in outPrefix + items[o[0]] + items[o[1]] + items[o[2]] + outSuffix }
        
        XCTAssertNotNil(possibleOutputs.index { $0.xmlData == data }, "One of the inputs should match")
    }
    
    func testEncodeIfPresent() throws {
        let encoder = XMLRPCEncoder()
        let obj = NilTest()
        let data = try encoder.encode(obj, autoWrappingStructures: true)
        let expected = xmlHeader + "<methodResponse><params><param><value><struct><member><name>opt1</name><value><i4>5</i4></value></member></struct></value></param></params></methodResponse>"
        
        XCTAssertEqual(data.xmlString, expected)
    }

    func testAllTestsIsComplete() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let linuxCount = type(of: self).allTests.count
            let darwinCount = type(of: self).defaultTestSuite.testCaseCount
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    static var allTests = [
        ("testSimpleEncode", testSimpleEncode),
        ("testWrappingEncode", testWrappingEncode),
        ("testMethodCallEncode", testMethodCallEncode),
        ("testEncodeIfPresent", testEncodeIfPresent),
        ("testAllTestsIsComplete", testAllTestsIsComplete),
    ]
}

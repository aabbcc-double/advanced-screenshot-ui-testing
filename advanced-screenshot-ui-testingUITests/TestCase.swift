/*
 MIT License
 
 Copyright (c) 2017 Shakhzod Ikromov <aabbcc.double@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import XCTest

class TestCase: XCTestCase {
    func compare(_ id: String, file: StaticString = #file, line: UInt = #line) {
        __save(withIdentifier: id)
        __compare(withIdentifier: id, file: file, line: line)
    }
}

private extension TestCase {
    var __should_save: Bool {
        return ProcessInfo.processInfo.environment["__should_save"] == "generate"
    }
    
    var __deviceName: String {
        return XCUIApplication().frame.size.debugDescription
    }
    
    func __save(withIdentifier id: String) {
        guard __should_save else { return }
        let directory = ProcessInfo.processInfo.environment["SRCROOT"]!
        let fileName = directory.appending("/\(id)\(self.__deviceName).png")
        let screenshot = XCUIApplication().screenshot().pngRepresentation
        let url = URL(fileURLWithPath: fileName)
        do {
           try screenshot.write(to: url)
        } catch {
            XCTAssertTrue(false)
        }
        print("Saved to: \(url)")
    }
    
    func __compare(withIdentifier id: String, file: StaticString = #file, line: UInt = #line) {
        let directory = ProcessInfo.processInfo.environment["SRCROOT"]!
        let fileName = directory.appending("/\(id)\(self.__deviceName).png")
        let url = URL(fileURLWithPath: fileName)
        
        let current = UIImage(data: XCUIApplication().screenshot().pngRepresentation)!
        do {
            let savedData = try Data(contentsOf: url)
            let saved = UIImage(data: savedData)!
        
            XCTAssertTrue(saved.fb_compare(with: current, tolerance: 0.1), file: file, line: line)
        } catch {
            XCTAssertTrue(false)
        }
    }
}

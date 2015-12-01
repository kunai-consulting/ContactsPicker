//
//  XCTAssertSwiftError.swift
//
//  Created by LCS on 6/17/15.
//  Released into public domain; use at your own risk.
//

import XCTest


func XCTempAssertThrowsError(message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ block: () throws -> ())
{
    do
    {
        try block()
        
        let msg = (message == "") ? "Tested block did not throw error as expected." : message
        XCTFail(msg, file: file, line: line)
    }
    catch {}
}


func XCTempAssertThrowsSpecificError(kind: ErrorType, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ block: () throws -> ())
{
    do
    {
        try block()
        
        let msg = (message == "") ? "Tested block did not throw expected \(kind) error." : message
        XCTFail(msg, file: file, line: line)
    }
    catch let error as NSError
    {
        let expected = kind as NSError
        if ((error.domain != expected.domain) || (error.code != expected.code))
        {
            let msg = (message == "") ? "Tested block threw \(error), not expected \(kind) error." : message
            XCTFail(msg, file: file, line: line)
        }
    }
}


func XCTempAssertNoThrowError(message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ block: () throws -> ())
{
    do {try block()}
    catch
    {
        let msg = (message == "") ? "Tested block threw unexpected error." : message
        XCTFail(msg, file: file, line: line)
    }
}


func XCTempAssertNoThrowSpecificError(kind: ErrorType, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ block: () throws -> ())
{
    do {try block()}
    catch let error as NSError
    {
        let unwanted = kind as NSError
        if ((error.domain == unwanted.domain) && (error.code == unwanted.code))
        {
            let msg = (message == "") ? "Tested block threw unexpected \(kind) error." : message
            XCTFail(msg, file: file, line: line)
        }
    }
}
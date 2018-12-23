//
//  VML.swift
//  Alamofire
//
//  Created by Emil Sjölander on 23/12/2018.
//

import Foundation

public class VML {
    public class func sayHello(to: String) -> String {
        let result = vml_hello(to)
        let swift_result = String(cString: result!)
        vml_hello_free(UnsafeMutablePointer(mutating: result))
        return swift_result
    }
}

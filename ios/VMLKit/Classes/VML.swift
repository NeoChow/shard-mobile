//
//  VML.swift
//  Alamofire
//
//  Created by Emil Sjölander on 23/12/2018.
//

import Foundation

public class StringCallback {
    let result: (String) -> Void
    
    public init(_ result: @escaping (String) -> Void) {
        self.result = result
    }
}

public class VML {
    public class func getKind(json: String, result: StringCallback) {
        vml_json_get_kind(json, Unmanaged.passUnretained(result).toOpaque(), { (context, c_kind) in
            let result: StringCallback = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
            result.result(String(cString: c_kind!))
        })
    }
}

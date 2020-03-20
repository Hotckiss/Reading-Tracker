//
//  TextFieldDelegates.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 25/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class IntermediateTextFieldDelegate: NSObject, UITextFieldDelegate {
    var nextField: UITextField?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextField?.becomeFirstResponder()
        return true
    }
}

class FinishTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

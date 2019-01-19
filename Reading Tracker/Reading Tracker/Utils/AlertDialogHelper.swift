//
//  AlertDialogHelper.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/19/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class AlertDialogHelper {
    public static var alertStyle: UIAlertController.Style {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .alert
        } else {
            return .actionSheet
        }
    }
}

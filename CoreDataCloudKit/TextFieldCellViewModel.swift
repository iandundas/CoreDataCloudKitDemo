//
//  TextFieldCellViewModel.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 30/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation


class TextFieldCellViewModel{
    
    typealias ValueDidChange = (String) -> ()
    
    internal var value: String?
    internal var valueDidChange: ValueDidChange?
    
}

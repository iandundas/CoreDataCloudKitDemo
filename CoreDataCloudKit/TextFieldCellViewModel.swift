//
//  TextFieldCellViewModel.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 30/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation


public class TextFieldCellViewModel{
    
    public typealias ValueDidChange = (String) -> ()
    
    public var value: String?
    public var valueDidChange: ValueDidChange?
    
}

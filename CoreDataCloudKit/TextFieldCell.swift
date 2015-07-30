//
//  TextFieldCell.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 30/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    internal var viewModel: TextFieldCellViewModel?{
        didSet{
            self.textField.text = viewModel?.value
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        
        textField.userInteractionEnabled = true
        
        return textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        viewModel?.valueDidChange?(textField.text)
        
        textField.userInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        
        self.viewModel = nil
        
        textField.userInteractionEnabled = false
    }
    
}

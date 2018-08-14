//
//  textCell.swift
//  HomePower
//
//  Created by triumph_sha on 2018/3/1.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import UIKit

class textCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var textValue: UITextField!
    
    var indexArray = 0
    var keyStr = String("")

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textValue.keyboardType = UIKeyboardType.numberPad
        textValue.returnKeyType = UIReturnKeyType.done
        textValue.keyboardAppearance = UIKeyboardAppearance.default
        
        textValue.delegate = self
        
        textValue.becomeFirstResponder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //[text resign]
        textValue.resignFirstResponder()
        
        // 获取相应的值，更新
        let value = textValue.text
        
        var mydic = Array<Dictionary<String,String>>()
        let filePath:String = NSHomeDirectory() + "/Documents/webs.plist"
        mydic = NSArray(contentsOfFile:filePath) as! Array<Dictionary<String,String>>
        if !mydic.isEmpty{
            mydic[indexArray][keyStr] = value
            NSArray(array:mydic).write(toFile: filePath, atomically: true)
            
            maindata = NSArray(contentsOfFile: filePath) as! Array<Dictionary<String, String>>
            
            
            //print(mydic)
        }
        
        
        
        return true
    }
    
    
    

}

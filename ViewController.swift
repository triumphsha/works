//
//  ViewController.swift
//  HomePower
//
//  Created by triumph_sha on 2018/2/23.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var mainWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainWebView.autoresizingMask = [.flexibleHeight]
        if let url = URL(string:"http://baidu.com")
        {
            let request = URLRequest(url: url)
            mainWebView.load(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  analyseViewController.swift
//  HomePower
//
//  Created by triumph_sha on 2018/2/25.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import UIKit
import WebKit

class analyseViewController: UIViewController {

    @IBOutlet weak var analyseWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        analyseWebView.autoresizingMask = [.flexibleHeight]
//        if let url = URL(string:"http://mornmark.com/homepower")
//        {
//            let request = URLRequest(url: url)
//            analyseWebView.load(request)
//        }
        
        /**加载 https 链接  **/
        //let myURL = URL(string: "http://192.168.2.186:8080")
        //let myRequest = URLRequest(url: myURL!)
        //webView.load(myRequest)
        
        /**加载本地 HTML文件**/
        //从主Bundle获取 HTML 文件的 url
        let fileURL =  Bundle.main.url(forResource: "CVCurve", withExtension: "html" )
        analyseWebView.loadFileURL(fileURL!,allowingReadAccessTo:Bundle.main.bundleURL);
        
        /**加载 html 内容**/
        //webView.loadHTMLString("<h1>h1</h1><img src='.html/images/h.png'>", baseURL: Bundle.main.bundleURL);
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    //js 和 swift 的交互
    extension ViewController: WKScriptMessageHandler {
        
        //接收 js 发来的消息
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            
            //判断消息通道
            if(message.name == "msgBridge"){
                //TODO ...
                //message.body（any 类型） 即前端 js 传来的数据，如果传字符串这里接收的就是字符串，如果传 json 对象或 js 对象 则这里是 NSDictionary
                print(message.body)
                let msg = message.body as! NSDictionary;
                
                //swift 调 js函数
                webView.evaluateJavaScript("funcforswift('\( msg["msg"]  as! String)')", completionHandler: {
                    (any, error) in
                    if (error != nil) {
                        print(error ?? "err")
                    }
                })
            }
            
        }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

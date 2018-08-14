//
//  SelfInfoViewController.swift
//  HomePower
//
//  Created by triumph_sha on 2018/4/4.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import UIKit
import Foundation
import Dispatch
/*public let keyArray = [ ["姓名", "联系方式","地址"],
                       ["序列号", "WIFI名称","WIFI密码","热点名称","热点密码"],
                        ["服务域名","上报间隔","允许上报","结算日"]
                    ] // keys*/

class SelfInfoViewController: UITableViewController {
    
    let subTitles:[String]=["个人信息","设备信息","数据信息"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.title = "我的信息"
        
        self.tabBarItem.image = UIImage(named: "ic_insert_chart_white")
        
        // get user confige data
        //gConfigData = NSArray(contentsOfFile: NSHomeDirectory()+"/Documents/webs.plist") as!Array<Dictionary<String, String>>
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gConfigData.count  //
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "UserInfoCellDataType")
        
        // Configure the cell...
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UserInfoCellDataType")
            cell!.accessoryType = .disclosureIndicator
        }
        
        // Configure the cell...  [subTitles[indexPath.row]]
        let dicdata = gConfigData[indexPath.row]
        cell!.textLabel!.text = (dicdata["name"] as! String)
        let dicsubdata = dicdata["Childrens"] as! [[String:Any]]
        if indexPath.row == 2{
            if (CCommonFunc.getTreeStructure(dicsubdata, "开启服务", "value") as! Bool){
                cell!.detailTextLabel!.text = "域名服务-开启"
            }
            else{
                cell!.detailTextLabel!.text = "域名服务-关闭"
            }
        }
        else if indexPath.row == 3{
            cell!.detailTextLabel!.text = "WIFI电表个数-" + "\(dicsubdata.count)"
        }
        else
        {
            cell!.detailTextLabel!.text = dicsubdata[0]["value"] as? String
        }
        cell!.imageView!.image = UIImage(named: "ic_directions_walk")
        
        //cell.linkBtn.setTitle(">", for: UIControlState.normal)//(for: UIControlState.application)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataview = DataViewController(nibName: "DataViewController", bundle: nil)
        
        dataview.mtitle = (gConfigData[indexPath.row]["name"] as! String)
        dataview.data = gConfigData[indexPath.row]["Childrens"] as! [Any] //[subTitles[indexPath.row]] as! [Any]
        
        self.navigationController?.pushViewController(dataview, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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


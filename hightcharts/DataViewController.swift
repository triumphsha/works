//
//  DataViewController.swift
//  HighFit
//
//  License: www.highcharts.com/license
//  Copyright © 2018 Highsoft AS. All rights reserved.
//

import UIKit

// data handle
protocol DataFormatDelegate {
    func textLabelData(data:[Any],index:Int)->String
    func detailTextLabelData(data:[Any],index:Int)->String
    func cellSetting(data:[Any],index:Int,cell:UITableViewCell) -> Void
}

class DataViewController: UITableViewController,UITextFieldDelegate {
    var mtitle:String?
    //var type:Int = 0
    var data: [Any]!
    var switchView: UISwitch!
    var textView:UITextField!
    //var datahandle:DataFormatDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView = UITableView(frame: view.bounds, style: .grouped)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.textView = UITextField(frame: CGRect(x: 0, y: 0, width: 240, height: 28))
        self.textView.clearButtonMode = .whileEditing
        self.textView.delegate = self
        //self.textView.addTarget(self, action: #selector(self.actionTextField), for: .editingChanged)
        
        self.switchView = UISwitch()
        self.switchView.addTarget(self, action: #selector(self.actionSwitch), for: .valueChanged)
        
        //let barButtonItem = UIBarButtonItem()
        //barButtonItem.add
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(self.setWifiMete))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("textField test:\r\n",string)
        
        if string == "\n"{
            // Show or hide chart on dashboard.
            var temp = self.data[textField.tag] as! [String:Any]
            let index = CCommonFunc.updateGConfig(temp,textField.text!)
            temp["value"] = textField.text
            temp["type"] = "editDetail"
            //self.data[textField.tag] = temp
            
            self.navigationController?.popViewController(animated: true)
            
            //
            reflashPreviousView(temp,index)
            
        }
        
        return true
    }
    
    private func reflashPreviousView(_ value:[String:Any],_ index:Int)
    {
        // use hoop
        if self.navigationController != nil{
            if self.navigationController!.viewControllers.count > 2{
                let popView = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count-1] as? DataViewController
                popView?.data[index] = value
                
                let previousView=self.navigationController!.viewControllers[self.navigationController!.viewControllers.count-2] as? DataViewController
                previousView?.data = gConfigData[2]["Childrens"] as! [Any]
                previousView?.tableView.reloadData()
                popView?.tableView.reloadData()
            }
            else if self.navigationController!.viewControllers.count > 1 {
                let popView = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count-1] as? DataViewController
                
                    popView?.data[index] = value
                    popView?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.mtitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.title
    }*/
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "HighFitCellData")
        
        let show = self.data[indexPath.row] as! [String:Any]
        if show.keys.contains("type")
        {
        // Configure the cell...
        if cell == nil {
            if show["type"] as! String == "editExecute"
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "HighFitCellData")
            }
            else
            {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "HighFitCellData")
            }
            
        }
        cell!.accessoryView = nil
        cell!.textLabel?.text = nil
        cell!.accessoryType = .none
        
        switch  show["type"] as! String{
        case "showList":
            break
        case "showDetail":
            //let showdata = data[index] as! [String:String]
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel?.text = (show["name"] as! String)
            let firstchildren = (show["Childrens"] as! [[String:Any]])[0]
            if firstchildren["type"] as! String == "switchDetail"
            {
                if firstchildren["value"] as! Bool
                {
                    cell!.detailTextLabel?.text = "打开"
                }
                else
                {
                    cell!.detailTextLabel?.text = "关闭"
                }
            }
            else
            {
                cell!.detailTextLabel?.text = (firstchildren["value"] as! String)
            }
            break
        case "readDetail":
            cell!.accessoryType = .none
            cell!.textLabel?.text = (show["name"] as! String)
            cell!.detailTextLabel?.text = (show["value"] as! String)
            break
        case "editDetail":
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel?.text = (show["name"] as! String)
            cell!.detailTextLabel?.text = (show["value"] as! String)
            break
        case "editExecute":
            cell!.selectionStyle = .none
            cell!.accessoryType = .detailDisclosureButton
            cell!.textLabel?.text = (show["name"] as! String)
            self.textView.tag = indexPath.row
            self.textView.text = (show["value"] as! String)
            cell!.accessoryView = self.textView
            break
        case "switchDetail":
            cell!.selectionStyle = .none
            cell!.textLabel?.text = (show["name"] as! String)
            self.switchView.tag = indexPath.row
            self.switchView.isOn = (show["value"] as! Bool)
            cell!.accessoryView = self.switchView
            break
        default:
            break
        }
        }
        else{
            cell = UITableViewCell(style: .value1, reuseIdentifier: "HighFitCellData")
            cell!.accessoryType = .none
            
            let date = Date(timeIntervalSince1970: TimeInterval(show["date"] as! Int ))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            cell!.textLabel?.text = dateFormatter.string(from: date)
            let temp = show["sample"] as! Int
            cell!.detailTextLabel?.text = "\(temp)"
        }
        //let data = self.data[indexPath.row] as! [String: Any]
        //self.datahandle.
        //cell!.accessoryType = .disclosureIndicator
        //cell!.textLabel?.text = self.datahandle?.textLabelData(data: self.data, index: indexPath.row)//String(describing: data[self.mdesc] as! Int)
        
        //self.datahandle?.cellSetting(data: self.data, index: indexPath.row, cell: cell!)
        return cell!
    }
    
    
    @objc func actionTextField(_ actionTextField: UITextField) {
        // Show or hide chart on dashboard.
        var temp = self.data[actionTextField.tag] as! [String:Any]
        temp["value"] = actionTextField.text
        self.data[actionTextField.tag] = temp
    }
    
    // send info to wifi meter
    @objc func setWifiMete()
    {
        let sendStr = CCommonFunc.getSendStr(type:self.mtitle!)
        //gArrayMeter[0].setWifiInfo(commStr: sendStr)
    }
    
@objc func actionSwitch(_ actionSwitch: UISwitch) {
    // Show or hide chart on dashboard.
    var temp = self.data[actionSwitch.tag] as! [String:Any]
    var value:Bool
    // temp["index"] as! Int
    if actionSwitch.isOn {
        //DashboardViewController.sharedDashboard().dataSourceAdd(self.configuration)
        temp["value"] = true
        value = true
    }
    else {
        //DashboardViewController.sharedDashboard().dataSourceRem(self.configuration)
        temp["value"] = false
        value = false
    }
    
    let index = CCommonFunc.updateGConfig(temp,value)
    //
    reflashPreviousView(temp,index)
    
    //self.data[actionSwitch.tag] = temp
}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let childinfo = self.data[1]
        let show = self.data[indexPath.row] as! [String:Any]
        if show.keys.contains("type"){
            
        
        if show["type"] as! String == "switchDetail" || show["type"] as! String == "readDetail"
        {
            return
        }
        if show["type"] as! String == "editExecute"
        {
            return
        }
        
        
        let dataview = DataViewController(nibName: "DataViewController", bundle: nil)
        
        dataview.mtitle = self.mtitle
        
        if show["type"] as! String == "editDetail"
        {
            var editData:[[String:Any]] = [show]
            editData[0]["type"] = "editExecute"
            dataview.data = editData
        }
        else if show["type"] as! String == "showDetail"
        {
            dataview.data = show["Childrens"] as! [[String:Any]]
        }
        
        //dataview.datahandle = self.
        self.navigationController?.pushViewController(dataview, animated: true)
        //print("sss:/r/n",self.navigationController?.viewControllers.count)
        }
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
    
    // MWRK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView {
            let tableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            tableViewHeaderFooterView.textLabel?.text = tableViewHeaderFooterView.textLabel?.text?.lowercased()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

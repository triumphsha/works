//
//  selfTableViewController.swift
//  HomePower
//
//  Created by triumph_sha on 2018/2/25.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import UIKit
import CoreData

//public var maindata = Array<Dictionary<String,String>>()
/*public let keyArray = [ ["姓名", "联系方式","地址"],
                        ["序列号", "WIFI名称","WIFI密码","热点名称","热点密码"],
                        ["服务域名","上报间隔","允许上报","结算日"]
                        ] */


class selfTableViewController: UITableViewController {
    
    //var maindata = Array<Dictionary<String,String>>()
    let subTitles:[String]=["个人信息","设备信息","数据信息"]
    let btnCaptions:[String] = [">",">",">"]
    var getentitle = [NSManagedObject]()    // 管理类型数组
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.image = UIImage(named: "ic_content_paste_white")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
       
        maindata = NSArray(contentsOfFile: NSHomeDirectory()+"/Documents/webs.plist") as! Array<Dictionary<String, String>>
        
        getentitle = entitleGet(name:"Voltage")
        
        print(getentitle.count)
    }
    
    // 获取实例信息
    func entitleGet(name:String) -> [NSManagedObject] {
        // 步骤一：获取总代理和托管对象总管
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        // 步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        
        // 步骤三：执行请求
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                return results
            }
            
        } catch  {
            fatalError("获取失败")
        }
        
        return []//let res = nil
    }
    
    private func saveEntitle(text: String) {
        //        步骤一：获取总代理和托管对象总管
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        //        步骤二：建立一个entity
        let entity = NSEntityDescription.entity(forEntityName: text, in: managedObectContext)
        
        let item = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        
        //        步骤三：保存文本框中的值到person
        item.setValue("1", forKey: "code")
        item.setValue(NSDate(), forKey: "date")
        item.setValue(1, forKey: "value01")
        item.setValue(2, forKey: "value02")
        item.setValue(3, forKey: "value03")
        item.setValue(4, forKey: "value04")
        item.setValue(5, forKey: "value05")
        item.setValue(6, forKey: "value06")
        item.setValue(7, forKey: "value07")
        item.setValue(8, forKey: "value08")
        item.setValue(9, forKey: "value09")
        item.setValue(10, forKey: "value10")
        
        //        步骤四：保存entity到托管对象中。如果保存失败，进行处理
//        do {
//            try managedObectContext.save()
//        } catch  {
//            fatalError("无法保存")
//        }
//
        appDelegate.saveContext()
        //        步骤五：保存到数组中，更新UI
        getentitle.append(item)
        let getitem = getentitle[getentitle.count-1]
        print(getitem.value(forKey: "value02") ?? 0)
        //getentitle.
    }
//    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
//        <#code#>
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let row = tableView.indexPathForSelectedRow!.row
        let destination = segue.destination as! userinfoTableViewController
        
        saveEntitle(text: "Voltage")
        destination.infoIndex = row
        destination.infoTitle = subTitles[row]
    }
    
    // 刷新数据信息
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1//maindata!.count
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //let data = maindata["root"] as! Array<AnyObject>
        return maindata.count//.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = String(describing:selfTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: id,for:indexPath) as! selfTableViewCell

        // Configure the cell...
        let dicdata = maindata[indexPath.row]
        cell.mainLabel?.text = dicdata[keyArray[indexPath.row][0]] as! String //["name"]//Dictionary.values( arraydata:0)
        cell.subLabel.text = subTitles[indexPath.row]
        
        cell.linkBtn.setTitle(">", for: UIControlState.normal)//(for: UIControlState.application)
        //cell.linkBtn.value(forKey: btnCaptions[indexPath.row])
        return cell
    }
    
    // prepare for change scene
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let row = tableView.indexPathForSelectedRow!.row
//        let destination = segue.destination as! userinfoTableViewController
//
//
//        //let data = maindata["root"] as! Array<AnyObject>
//        //let arraydata = data[row] as! Dictionary<String,Dictionary<String,String>>//Array(data.values)
//
//        destination.dicshow = maindata[row]//Array(arraydata.values)[0]
//    }
 
    // select operate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0,1,2:
            performSegue(withIdentifier: "userinfoTableView", sender: self)
            break
        default:
            break
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

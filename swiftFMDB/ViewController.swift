//
//  ViewController.swift
//  fmdbTest
//
//  Created by ljkj on 2018/8/15.
//  Copyright © 2018年 ljkj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let p1 = LJSqltManager.shared
        var array = [[String:Any]]()
        for i in 1..<22 {
            
            let statusid = i.description
            let dic = ["statusid":statusid.description,"status":"测试aaaa--\(i.description)"]
            array.append(dic)
        }
        LJSqltManager.shared.updateStatus(userid: "1", array: array)
        let arr = LJSqltManager.shared.loadData(userid: "1")
        print("\(arr)")
    }


}


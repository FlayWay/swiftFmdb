//
//  LJSqltManager.swift
//  fmdbTest
//
//  Created by ljkj on 2018/8/15.
//  Copyright © 2018年 ljkj. All rights reserved.
//

import UIKit
import FMDB

/// 最大存储时间
private let maxDBCacheTime = -5 * 24 * 60 * 60

class LJSqltManager {
    
    static let shared = LJSqltManager()
    
    let queue:FMDatabaseQueue
    
    private init() {
        
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true)[0]
        path =  (path as NSString).appendingPathComponent(dbName)
        print("数据存储位置---\(path)")
        // 创建数据库
        queue = FMDatabaseQueue(path: path)
        
        createTable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
    
    @objc private func clearDBCache() {
        
        print("清除缓存")
        let dateStr = Date.lj_dateString(time: TimeInterval(maxDBCacheTime))
        
        let sql = "DELETE FROM status WHERE createTime < ?;"
        queue.inDatabase { (db) in
            
            if db.executeUpdate(sql, withArgumentsIn: [dateStr]) == true {
                
                print("删除了\(db.changes)个")
            }
        }
        
    }

    
}

private extension LJSqltManager {
    
     func createTable() {
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
            let sql = try? String(contentsOfFile: path)
        else {
            
            return
        }
        
        print("测试====\(sql)")
        queue.inDatabase { (db) in
            if db.executeStatements(sql) == true {
                print("成功")
            }else {
                print("失败")
            }
        }
        
        print("over")
    }
}


// MARK: - 操作数据库
extension LJSqltManager {
    
    
    
    func loadData(userid:String,sinceId:Int64=0,max_id:Int64=0) -> [String] {
        
        var sql = "SELECT userid,statusid,status FROM status \n"
        sql += "WHERE userid = \(userid) \n"
        if sinceId > 0 {
            sql += "AND statusid < \(sinceId) \n"
        }else if max_id > 0 {
            sql += "AND statusid > \(sinceId) \n"
        }
        sql += "ORDER BY statusid DESC LIMIT 20;"
        
        print("\(sql)")
        
       let array = execRecordSet(sql: sql)
        var result = [String]()
        for dict in array {
            
            guard let str = dict["status"] as? String else {
                continue
            }
            
            result.append(str)
        }
        
      return result
    }
    
    
    func execRecordSet(sql:String) -> [[String:Any]] {
        
        var result = [[String:Any]]()
        
        queue.inDatabase { (db) in
            
            guard let rs = db.executeQuery(sql, withArgumentsIn: []) else {
                return
            }
            
            while rs.next() {
                
                let column = rs.columnCount
                
                for col in 0..<column {
                    
                    guard let colName = rs.columnName(for: col),
                        let value = rs.object(forColumnIndex: col)
                        else {
                            continue
                    }
                    result.append([colName:value])
                }
            }
            
        }
        
        return result
    }
    
    
    func updateStatus(userid:String,array:[[String:Any]]) {
        
       let sql = "INSERT OR REPLACE INTO status (userid,statusid,status) VALUES(?,?,?);"
        
        // 利用队列进行事务操作，队列中的打开、关闭、回滚事务等都已经被封装
        queue.inTransaction { (db, rollback) in
            
            for dic in array {
                
                guard let statusid = dic["statusid"],
                    let status = dic["status"] else {
                        continue
                }
                if db.executeUpdate(sql, withArgumentsIn: [userid,statusid,status]) == false {
                    print("插入失败")
                    rollback.pointee = true
                    break
                }
            }
            
        }
        
    }
    
}


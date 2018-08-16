//
//  Date+Extension.swift
//  fmdbTest
//
//  Created by ljkj on 2018/8/15.
//  Copyright © 2018年 ljkj. All rights reserved.
//

import Foundation

private let dateFormatter = DateFormatter()

extension Date {
    
    static func lj_dateString(time: TimeInterval) -> String {
        
        let date = Date(timeIntervalSinceNow: time)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
}

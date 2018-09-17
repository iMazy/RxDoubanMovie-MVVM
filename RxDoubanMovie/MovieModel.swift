//
//  MovieModel.swift
//  RxDoubanMovie
//
//  Created by Mazy on 2018/9/17.
//  Copyright © 2018年 mazy. All rights reserved.
//

import SwiftyJSON

struct Top250 {
    var count: Int
    var start: Int
    var subject: [MovieModel]
    var title: String
    var total: Int

    init(json: JSON) {
        self.count   = json["count"].intValue
        self.start   = json["start"].intValue
        self.subject = json["subjects"].arrayValue.map({ MovieModel(json: $0) })
        self.title   = json["title"].stringValue
        self.total   = json["total"].intValue
    }
    
}

struct MovieModel {
    
    var id: String
    var collect_count: Int
    var subtype: String
    var title: String
    var year: Int
    
    init(json: JSON) {
        self.id            = json["id"].stringValue
        self.collect_count = json["collect_count"].intValue
        self.subtype       = json["subtype"].stringValue
        self.title         = json["title"].stringValue
        self.year          = json["year"].intValue
    }
}

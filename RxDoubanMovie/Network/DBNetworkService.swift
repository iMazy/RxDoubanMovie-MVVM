//
//  DBNetworkService.swift
//  RxDoubanMovie
//
//  Created by Mazy on 2018/9/13.
//  Copyright © 2018年 mazy. All rights reserved.
//

import Foundation
import Moya

//初始化豆瓣FM请求的provider
let DBNetworkProvider = MoyaProvider<DBNetworkAPI>()

/** 下面定义豆瓣请求的（供provider使用）**/
//请求分类
public enum DBNetworkAPI {
    case inTheaters // 热映
    case comingSoon // 即将上映
    case top250(String)     // top250
    case usBox      // 北美票房榜
    case newMovies  // 新片榜
    
    case movieDetail(String) // 影片详情
    case celebrityDetail(String)   // 影人条目信息
}

//请求配置
extension DBNetworkAPI: TargetType {
    //服务器地址
    public var baseURL: URL {
        return URL(string: "https://api.douban.com")!
    }
    
    //各个请求的具体路径
    public var path: String {
        switch self {
        case .inTheaters:
            return "/v2/movie/in_theaters"
        case .comingSoon:
            return "/v2/movie/coming_soon"
        case .top250:
            return "/v2/movie/top250"
        case .usBox:
            return "/v2/movie/us_box"
        case .newMovies:
            return "/v2/movie/new_movies"
        case .movieDetail(let id):
            return "/v2/movie/subject/" + id
        case .celebrityDetail(let id):
            return "/v2/movie/celebrity/" + id
        }
    }
    
    //请求类型
    public var method: Moya.Method {
        return .get
    }
    
    //请求任务事件（这里附带上参数）
    public var task: Task {
        switch self {
        case .inTheaters:
            return .requestParameters(parameters: ["start":"0", "count":"1"], encoding: URLEncoding.default)
        case .top250(let page):
            return .requestParameters(parameters: ["start":page, "count":"10"], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    //是否执行Alamofire验证
    public var validate: Bool {
        return false
    }
    
    //这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    //请求头
    public var headers: [String: String]? {
        return nil
    }
}

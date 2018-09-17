//
//  ViewController.swift
//  RxDoubanMovie
//
//  Created by Mazy on 2018/9/11.
//  Copyright © 2018年 mazy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Moya
import SwiftyJSON

class ViewController: UIViewController {

    /// ARC & Rx 垃圾回收
    let disposeBag = DisposeBag()
    var tableView: UITableView!
    var movieObservable = BehaviorRelay<[MovieModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        
//        let items = Observable.just(["swift", "OC", "Python"])
        
        
        movieObservable.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
            cell.textLabel?.text = element.title
            return cell
        }.disposed(by: disposeBag)
        
        
        DBNetworkProvider.rx.request(.top250("0"))
            .subscribe(onSuccess: { data in
                // 数据处理
                guard let json = try? JSON(data: data.data) else { return }
                let top250 = Top250(json: json)
                print(top250.subject)
                
                self.movieObservable.accept(top250.subject)
                
                print(json)
            }, onError: { error in
                print("数据请求失败! 错误原因: ", error)
            }).disposed(by: disposeBag)
    }

}


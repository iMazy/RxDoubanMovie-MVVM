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
    var currentPage: Int = 0
    var dataSource: [MovieModel] = []
    
    var viewModel: MovieViewModel = MovieViewModel()
    private var vmOutput: MovieViewModel.Output?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        
        
        let input = MovieViewModel.Input()
        vmOutput = viewModel.transform(input: input)
        
        vmOutput?.sections.asObservable().bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
            cell.textLabel?.text = element.title
            return cell
            }.disposed(by: disposeBag)
        
//        movieObservable.bind(to: tableView.rx.items) { tableView, row, element in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
//            cell.textLabel?.text = element.title
//            return cell
//        }.disposed(by: disposeBag)
        
        
        tableView.es.addPullToRefresh(animator: GSRefreshHeaderAnimator()) {
            input.requestCommand.onNext(false)
        }
        
        tableView.es.addInfiniteScrolling(animator: GSRefreshFooterAnimator()) {
            input.requestCommand.onNext(true)
        }
        
        vmOutput?.refreshEnd.asObservable().subscribe(onNext: { _ in
            self.tableView.es.stopLoadingMore()
            self.tableView.es.stopPullToRefresh()
        }).disposed(by: disposeBag)
    }

}

// MARK: - network
extension ViewController {
    
    func loadDataWithPage(page: Int) {
        
        DBNetworkProvider.rx.request(.top250("\(page)"))
            .subscribe(onSuccess: { data in
                // 数据处理
                guard let json = try? JSON(data: data.data) else { return }
                let top250 = Top250(json: json)
                print(top250.subject)
                if page == 0 {
                    self.tableView.es.stopPullToRefresh()
                    self.tableView.es.stopLoadingMore()
                    self.dataSource = top250.subject
                    self.movieObservable.accept(top250.subject)
                    print(self.dataSource)
                } else {
                    self.tableView.es.stopLoadingMore()
                    self.currentPage = page
                    self.dataSource += top250.subject
                    print(self.dataSource)
//                    var currentMovies = self.movieObservable.value
//                    currentMovies += top250.subject
                    self.movieObservable.accept(self.dataSource)
                }
                
                print(json)
            }, onError: { error in
                print("数据请求失败! 错误原因: ", error)
            }).disposed(by: disposeBag)
        
    }
}


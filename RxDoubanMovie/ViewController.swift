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
    private let disposeBag = DisposeBag()
    private var tableView: UITableView!
    
    private var viewModel: MovieViewModel = MovieViewModel()
    private var vmOutput: MovieViewModel.Output?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "RxSwift + MVVM + Refresh"
        
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
        
        tableView.es.addPullToRefresh(animator: GSRefreshHeaderAnimator()) {
            input.requestCommand.onNext(false)
        }
        
        tableView.es.addInfiniteScrolling(animator: GSRefreshFooterAnimator()) {
            input.requestCommand.onNext(true)
        }
        
        vmOutput?.refreshEnd.asObservable().subscribe(onNext: { loadMore in
            if loadMore {
                self.tableView.es.stopLoadingMore()
            } else {
                self.tableView.es.stopPullToRefresh()
            }
        }).disposed(by: disposeBag)
        
        tableView.es.startPullToRefresh()
    }
}

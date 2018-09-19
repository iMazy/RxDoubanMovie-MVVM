//
//  MovieViewModel.swift
//  RxDoubanMovie
//
//  Created by Mazy on 2018/9/17.
//  Copyright © 2018年 mazy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

protocol XMViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class MovieViewModel {
    var disposeBag = DisposeBag()
    private var models = BehaviorRelay<[MovieModel]>(value: [])
    private var currentPage: Int = 0
    private var dataSource: [MovieModel] = []
}

extension MovieViewModel: XMViewModelType {
    
    struct Input {
         // 外界通过该属性告诉viewModel加载数据（传入的值是为了标志是否重新加载）
        let requestCommand = PublishSubject<Bool>()
    }
    
    struct Output {
        // tableView的sections数据
        let sections: Driver<[MovieModel]>
        // 告诉外界的tableView当前的刷新状态
        let refreshStatus = BehaviorRelay<RefreshStatus>(value: .none)
        
        init(sections: Driver<[MovieModel]>) {
            self.sections = sections
        }
    }
    
    func transform(input: MovieViewModel.Input) -> MovieViewModel.Output {
        
        let tempSections = models.asObservable().asDriver(onErrorJustReturn: [])
        let output = Output(sections: tempSections)
        
        input.requestCommand.subscribe(onNext: { [unowned self] loadMore in
            
            let page = loadMore ? self.currentPage + 5 : 0
            DBNetworkProvider.rx.request(.top250("\(page)"))
                .subscribe(onSuccess: { data in
                    output.refreshStatus.accept(loadMore ? .endFooterRefresh : .endHeaderRefresh)
                    // 数据处理
                    guard let json = try? JSON(data: data.data) else { return }
                    print(json)
                    let top250 = Top250(json: json)
                    if page == 0 {
                        self.models.accept(top250.subject)
                    } else {
                        self.currentPage = page
                        self.models.accept(self.models.value + top250.subject)
                    }
                }, onError: { error in
                    output.refreshStatus.accept(loadMore ? .endFooterRefresh : .endHeaderRefresh)
                    print("数据请求失败! 错误原因: ", error)
                }).disposed(by: self.disposeBag)
            
        }).disposed(by: disposeBag)
        
        return output
    }
}

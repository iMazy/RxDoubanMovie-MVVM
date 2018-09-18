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
    private var vmDatas = BehaviorRelay<[MovieModel]>(value: [])
    private var currentPage: Int = 0
    private var dataSource: [MovieModel] = []
}

extension MovieViewModel: XMViewModelType {
    
    struct Input {
        let requestCommand = PublishSubject<Bool>()
    }
    
    struct Output {
        let sections: Driver<[MovieModel]>
        let refreshEnd = BehaviorRelay<Bool>(value: false)
        init(sections: Driver<[MovieModel]>) {
            self.sections = sections
        }
    }
    
    func transform(input: MovieViewModel.Input) -> MovieViewModel.Output {
        
        let tempSections = vmDatas.asObservable().asDriver(onErrorJustReturn: [])
        let output = Output(sections: tempSections)
        
        input.requestCommand.subscribe(onNext: { [unowned self] loadMore in
      
            let page = loadMore ? self.currentPage + 5 : 0
            DBNetworkProvider.rx.request(.top250("\(page)"))
                .subscribe(onSuccess: { data in
                    output.refreshEnd.accept(loadMore)
                    // 数据处理
                    guard let json = try? JSON(data: data.data) else { return }
                    
                    let top250 = Top250(json: json)
                    if page == 0 {
                        self.vmDatas.accept(top250.subject)
                        self.dataSource = top250.subject
                    } else {
                        self.currentPage = page
                        self.dataSource += top250.subject
                        self.vmDatas.accept(self.dataSource)
                    }
                }, onError: { error in
                    print("数据请求失败! 错误原因: ", error)
                }).disposed(by: self.disposeBag)
            
        }).disposed(by: disposeBag)
        
        return output
    }
}

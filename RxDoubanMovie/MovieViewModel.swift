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

protocol XMViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class MovieViewModel {
    var disposeBag = DisposeBag()
    private var vmDatas = BehaviorRelay<[String]>(value: [])
    private var page: Int = 1
}

extension MovieViewModel: XMViewModelType {
    
    struct Input {
        let requestCommand = PublishSubject<Bool>()
    }
    
    struct Output {
        let sections: Driver<[String]>
        let refreshEnd = Variable<Bool>(false)
        init(sections: Driver<[String]>) {
            self.sections = sections
        }
    }
    
    func transform(input: MovieViewModel.Input) -> MovieViewModel.Output {
        let tempSections = vmDatas.asObservable().asDriver(onErrorJustReturn: [])
        let output = Output(sections: tempSections)
        
        input.requestCommand.subscribe(onNext: { [weak self] isPull in
            
        }).disposed(by: disposeBag)
        return output
    }
}

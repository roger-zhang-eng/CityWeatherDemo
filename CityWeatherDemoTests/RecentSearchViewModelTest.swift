//
//  RecentSearchViewModelTest.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 1/6/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking

class RecentSearchViewModelTest: XCTestCase {
    let disposeBag = DisposeBag()
    var scheduler: TestScheduler!
    var viewModel: RecentSearchViewModel!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        viewModel = RecentSearchViewModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeleteAll() {
         let response = scheduler.createObserver(Bool.self)
         
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: self.viewModel.input.deleteAllTrigger)
            .disposed(by: disposeBag)
            
        self.viewModel.output?.needConfirmDeleteAll
            .map { return true }
            .bind(to: response)
            .disposed(by: disposeBag)

            scheduler.start()
            
            XCTAssertEqual(response.events, [.next(10, true)])
    }
    
    func testDeleteAllConfirm() {
         let response = scheduler.createObserver(Bool.self)
         
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: self.viewModel.input.deleteAllConfirm)
            .disposed(by: disposeBag)
            
        self.viewModel.output?.refreshTableView
            .map { return true }
            .bind(to: response)
            .disposed(by: disposeBag)

            scheduler.start()
            
            XCTAssertEqual(response.events, [.next(10, true)])
    }
    
    func testViewDismiss() {
         let response = scheduler.createObserver(Bool.self)
         
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: self.viewModel.input.viewDismiss)
            .disposed(by: disposeBag)
            
        self.viewModel.output?.dismissView
            .map { return true }
            .bind(to: response)
            .disposed(by: disposeBag)

            scheduler.start()
            
            XCTAssertEqual(response.events, [.next(10, true)])
    }

}

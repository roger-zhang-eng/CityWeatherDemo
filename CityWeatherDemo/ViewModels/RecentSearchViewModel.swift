//
//  RecentSearchViewModel.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Action

struct RecentSearchViewModelInput {
    let editModeTrigger: PublishSubject<Void>
    let deleteTrigger: PublishSubject<Void>
    let cancelTrigger: PublishSubject<Void>
    let selectCellItem: PublishSubject<IndexPath>
}

struct RecentSearchViewModelOutput {
    let refreshTableView: Observable<Void>
    let updateDisplay: Observable<Void>
    let updateDeleteNumber: Observable<Int>
    let editModeTableViewCellCheckStateSwitchTriger: Observable<IndexPath>
    let dismissView: Observable<Void>
}

protocol RecentSearchProtocol {
    var dataSource: [CityInfo] { get }
    var deleteIndexSet: Set<Int> { get }
    var isEditMode: Bool { get }
    var input: RecentSearchViewModelInput { get }
    var output: RecentSearchViewModelOutput? { get }
}

class RecentSearchViewModel: RecentSearchProtocol {
    static let recentSearchCitiesKey: String = "recentSearchCitiesKey"
    
    private var savedRecentSearch = UserDefaultsProperty<[CityInfo]>(key: RecentSearchViewModel.recentSearchCitiesKey)
    
    var dataSource: [CityInfo] {
        get {
            return self.savedRecentSearch.savedSearchCities
        }
    }
    
    let input: RecentSearchViewModelInput
    var output: RecentSearchViewModelOutput?
    
    private let disposeBag = DisposeBag()
    var isEditMode = false
    private let internalDisplayUpdateTrigger = PublishSubject<Void>()
    private let internalViewDismissTrigger = PublishSubject<Void>()
    private let internalRefreshTableViewTrigger = PublishSubject<Void>()
    private let internalUpdateDeleteNumberTrigger = PublishSubject<Int>()
    var deleteIndexSet = Set<Int>()
    
    init() {
        input = RecentSearchViewModelInput(editModeTrigger: PublishSubject<Void>(),
                                           deleteTrigger: PublishSubject<Void>(),
                                           cancelTrigger: PublishSubject<Void>(),
                                           selectCellItem: PublishSubject<IndexPath>())
        
        setupBinding()
    }
    
    func setupBinding() {
        input.editModeTrigger
            .subscribe(onNext: {
                [unowned self] (_) in
                self.isEditMode = true
                self.internalDisplayUpdateTrigger.onNext(())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        input.deleteTrigger
        .subscribe(onNext: {
            [unowned self] (_) in
            self.deleteItemFromDataSource()
            self.deleteIndexSet.removeAll()
            self.isEditMode = false
            self.internalRefreshTableViewTrigger.onNext(())
            self.internalDisplayUpdateTrigger.onNext(())
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        input.cancelTrigger
        .subscribe(onNext: {
            [unowned self] (_) in
            if self.isEditMode {
                self.isEditMode = false
                self.deleteIndexSet.removeAll()
                self.internalDisplayUpdateTrigger.onNext(())
            } else {
                self.internalViewDismissTrigger.onNext(())
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)

        input.selectCellItem
            .subscribe(onNext: {
                [unowned self] (indexPath) in
                guard indexPath.row < self.dataSource.count else {
                    return
                }
                
                if self.isEditMode {
                    if self.deleteIndexSet.contains(indexPath.row) {
                        self.deleteIndexSet.remove(indexPath.row)
                    } else {
                        self.deleteIndexSet.insert(indexPath.row)
                    }
                    self.internalUpdateDeleteNumberTrigger.onNext(self.deleteIndexSet.count)
                } else {
                    let userData: [String: Any] = [
                        "cityData" : self.dataSource[indexPath.row]
                    ]
                    
                    NotificationCenter.default.post(name: .updateCityWeather, object: nil, userInfo: userData)
                    
                    self.internalViewDismissTrigger.onNext(())
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        output = RecentSearchViewModelOutput(refreshTableView: internalRefreshTableViewTrigger.asObservable(),
                                             updateDisplay: internalDisplayUpdateTrigger.asObservable(),
                                             updateDeleteNumber: internalUpdateDeleteNumberTrigger.asObservable(),
                                             editModeTableViewCellCheckStateSwitchTriger: input.selectCellItem
                                                                                                .filter { [unowned self] _ in
                                                                                                    return self.isEditMode
                                                                                                }
                                                                                                .asObservable(),
                                             dismissView: internalViewDismissTrigger.asObservable())
    }
    
    private func deleteItemFromDataSource() {
        guard deleteIndexSet.count > 0 && deleteIndexSet.count <= dataSource.count else {
            return
        }
        
        let originSource  = self.dataSource
        var shapedDataSource = [CityInfo]()
        for (index, item) in originSource.enumerated()
        {
            if deleteIndexSet.contains(index) {
                continue
            } else {
                shapedDataSource.append(item)
            }
        }
        
        self.savedRecentSearch.savedSearchCities = shapedDataSource
    }
}

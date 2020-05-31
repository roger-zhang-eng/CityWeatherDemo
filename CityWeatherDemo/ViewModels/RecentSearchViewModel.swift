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
    let deleteAllTrigger: PublishSubject<Void>
    let deleteAllConfirm: PublishSubject<Void>
    let viewDismiss: PublishSubject<Void>
    let deleteCellItem: PublishSubject<IndexPath>
    let presentCityWeather: PublishSubject<IndexPath>
    let refreshDataSourceTrigger: PublishSubject<Void>
}

struct RecentSearchViewModelOutput {
    let refreshTableView: Observable<Void>
    let needConfirmDeleteAll: Observable<Void>
    let dismissView: Observable<Void>
}

protocol RecentSearchProtocol {
    var dataSource: [CityInfo] { get }
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
    
    
    init() {
        input = RecentSearchViewModelInput(deleteAllTrigger: PublishSubject<Void>(),
                                           deleteAllConfirm: PublishSubject<Void>(),
                                           viewDismiss: PublishSubject<Void>(),
                                           deleteCellItem: PublishSubject<IndexPath>(),
                                           presentCityWeather: PublishSubject<IndexPath>(),
                                           refreshDataSourceTrigger: PublishSubject<Void>())
        
        setupBinding()
    }
    
    func setupBinding() {
        input.deleteAllConfirm
            .subscribe(onNext: {
                [unowned self] (_) in
                self.savedRecentSearch.savedSearchCities = [CityInfo]()
                self.input.refreshDataSourceTrigger.onNext(())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        input.deleteCellItem
        .subscribe(onNext: {
            [unowned self] (indexPath) in
            var currentArray = self.savedRecentSearch.savedSearchCities
            if indexPath.row < currentArray.count {
                currentArray.remove(at: indexPath.row)
                self.savedRecentSearch.savedSearchCities = currentArray
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        input.presentCityWeather
            .take(1)
            .subscribe(onNext: {
                [unowned self] (indexPath) in
                guard indexPath.row < self.dataSource.count else {
                    return
                }
                
                let userData: [String: Any] = [
                    "cityData" : self.dataSource[indexPath.row]
                ]
                
                NotificationCenter.default.post(name: .updateCityWeather, object: nil, userInfo: userData)
                
                self.input.viewDismiss.onNext(())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        output = RecentSearchViewModelOutput(refreshTableView: input.refreshDataSourceTrigger.asObservable(),
                                             needConfirmDeleteAll: input.deleteAllTrigger.asObservable(),
                                             dismissView: input.viewDismiss.asObservable())
    }
}

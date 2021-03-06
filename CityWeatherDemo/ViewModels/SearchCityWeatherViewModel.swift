//
//  SearchCityWeatherViewModel.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Action

enum WeatherDetailType {
    // swiftlint:disable:next identifier_name
    case sunTime(Int, Int), description(String), temperature(String), wind(String), humidity(String)

    func text() -> String {
        switch self {
        case .sunTime:
            return ""
        case .description(let text):
            return text
        case .temperature(let text):
        return text
        case .wind(let text):
        return text + " meter/sec"
        case .humidity(let text):
        return text + " %"
        }
    }

    func sunTimeData() -> (Int, Int) {
        switch self {
        case .sunTime(let sunrise, let sunset):
            return (sunrise, sunset)
        default:
            return (0, 0)
        }
    }
}

struct SearchCityViewModelInput {
    let countryCodeUpdate: PublishSubject<String>
    let searchContentTrigger: PublishSubject<String>
    let gpsLocationTrigger: PublishSubject<Void>
    let refreshWeather: PublishSubject<Void>
    let recentSearchView: PublishSubject<Void>
}

struct SearchCityViewModelOutput {
    let refreshTableView: Observable<Void>
    let presentRecentSearch: Observable<Void>
    let isLoading: Observable<Bool>
    let countryCodeDone: Observable<Bool>
    let error: Observable<ServiceError>
}

protocol SearchCityWeatherProtocol {
    var input: SearchCityViewModelInput { get }
    var output: SearchCityViewModelOutput? { get }
    var countryList: [String] { get }
    var dataSource: [WeatherDetailType] { get }
    var dataUpdateTime: Date { get }
    var latestWeatherData: WeatherCityData? { get }
    func loadSavedWeatherData()
}

class SearchCityWeatherViewModel: SearchCityWeatherProtocol {
    static let latestWeatherDataKey: String = "latestWeatherDataKey"
    static let latestWeatherTimeKey: String = "latestWeatherTimeKey"

    let input: SearchCityViewModelInput
    var output: SearchCityViewModelOutput?

    private let weatherService: DownloadProtocol
    private let countryCodeDecoder: CountryCodeDecodeProtocol
    private let locationService: LocationServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    private let disposeBag = DisposeBag()

    private let enableCountryCodeFilterTrigger: PublishSubject<Bool>
    private let downloadIndicatorTrigger: PublishSubject<Bool>
    private let downloadServiceRunning: BehaviorRelay<Bool>

    private var savedLatestWeatherCity = UserDefaultsProperty<WeatherCityData>(key: SearchCityWeatherViewModel.latestWeatherDataKey)
    private var savedLatestWeatherTime = UserDefaultsProperty<Date>(key: SearchCityWeatherViewModel.latestWeatherTimeKey)
    private var savedRecentSearch = UserDefaultsProperty<[CityInfo]>(key: RecentSearchViewModel.recentSearchCitiesKey)

    var countryList = [String]()
    var dataSource = [WeatherDetailType]()
    var dataUpdateTime: Date {
        get {
            return self.savedLatestWeatherTime.dateValue ?? Date()
        }
    }
    var latestWeatherData: WeatherCityData? {
        get {
            return self.savedLatestWeatherCity.savedWeatherData
        }
    }
    private let filteredCountryCode: BehaviorRelay<String>
    private var jsonFeedAction: Action<SearchType, WeatherCityData>!
    private let weatherDataRefreshTrigger = PublishSubject<Void>()
    private let countryCodeDecode = PublishSubject<Bool>()
    private let serviceErrorTrigger = PublishSubject<ServiceError>()
    private let networkConnected = BehaviorRelay<Bool>(value: true)
    private var needSearchLocation: SearchType?
    private let searchCityTrigger = PublishSubject<SearchType>()
    private var needRecordSearch = true

    init(weatherService: DownloadProtocol,
         countryCodeDecoder: CountryCodeDecodeProtocol,
         locationService: LocationServiceProtocol,
         networkMonitor: NetworkMonitorProtocol) {
        self.weatherService = weatherService
        self.countryCodeDecoder = countryCodeDecoder
        self.locationService = locationService
        self.networkMonitor = networkMonitor
        self.filteredCountryCode = BehaviorRelay<String>(value: "AU")

        input = SearchCityViewModelInput(countryCodeUpdate: PublishSubject<String>(),
                      searchContentTrigger: PublishSubject<String>(),
                      gpsLocationTrigger: PublishSubject<Void>(),
                      refreshWeather: PublishSubject<Void>(),
                      recentSearchView: PublishSubject<Void>())

        enableCountryCodeFilterTrigger = PublishSubject<Bool>()
        downloadIndicatorTrigger = PublishSubject<Bool>()
        downloadServiceRunning = BehaviorRelay<Bool>.init(value: false)

        NotificationCenter.default.rx
            .notification(.loadCityList)
            .subscribe(onNext: {
                [unowned self] (notification) in
                self.handleLoadCityListNotification(notification)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
        .notification(.updateCityWeather)
        .subscribe(onNext: {
            [unowned self] (notification) in
            self.presentSelectedRecentSearch(notification)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)

        setupBinding()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        networkMonitor.input.triggerMonitor.onNext((false))
    }

    @objc
    private func handleLoadCityListNotification(_ notification: Notification) {
        countryList = countryCodeDecoder.countryList()
        countryCodeDecode.onNext(true)
    }

    @objc
    func presentSelectedRecentSearch(_ notification: Notification) {
        guard let userData = notification.userInfo as? [String: CityInfo],
            let cityInfo = userData["cityData"] else {
            return
        }

        var searchType: SearchType?
        if cityInfo.id != nil &&  cityInfo.id! > 0 {
            searchType = SearchType.cityId(String(cityInfo.id!))
        } else if cityInfo.lat != nil && cityInfo.lon != nil {
            let latStr = String(format: "%.4f", cityInfo.lat!)
            let lonStr = String(format: "%.4f", cityInfo.lon!)
            searchType = SearchType.location(latStr, lonStr)
        } else if cityInfo.name != nil && !cityInfo.name!.isEmpty && !cityInfo.name!.contains(" ")
            && cityInfo.country != nil && !cityInfo.country!.isEmpty {
            searchType = SearchType.cityName(cityInfo.name!, cityInfo.country!)
        }

        guard searchType != nil else {
            return
        }

        needRecordSearch = false
        searchCityTrigger.onNext(searchType!)
    }

    private func setupBinding() {

        downloadServiceBinding()
        inputBinding()

        downloadIndicatorTrigger
            .bind(to: downloadServiceRunning)
            .disposed(by: disposeBag)

        searchCityTrigger
            .filter {
                [unowned self] (searchValue) in
                if !self.networkConnected.value {
                    self.needSearchLocation = searchValue
                    self.serviceErrorTrigger.onNext(ServiceError.network)
                }
                return self.networkConnected.value
            }
            .bind(to: jsonFeedAction.inputs)
            .disposed(by: disposeBag)

        output = SearchCityViewModelOutput(
                        refreshTableView: weatherDataRefreshTrigger.asObservable(),
                        presentRecentSearch: input.recentSearchView
                                            .asObservable(),
                        isLoading: downloadServiceRunning
                                    .asObservable(),
                        countryCodeDone: countryCodeDecode.asObservable(),
                        error: serviceErrorTrigger.asObservable()
        )

        locationServiceBinding()
        networkBinding()

        //Init country code list data parse in background
        initLoadBinding()
    }

    private func inputBinding() {
        input.searchContentTrigger
            .filter {
                [unowned self] (searchText) in
                if self.networkConnected.value {
                    debugPrint("Request fetch weather data, during isDownloading \(self.downloadServiceRunning.value)")
                    return !self.downloadServiceRunning.value
                } else {
                    if let _ = UInt(searchText) {
                        self.needSearchLocation = SearchType.zipCode(searchText, self.filteredCountryCode.value)
                    } else {
                        self.needSearchLocation = SearchType.cityName(searchText, self.filteredCountryCode.value)
                    }

                    self.serviceErrorTrigger.onNext(ServiceError.network)
                    return false
                }
            }
            .map({
                [unowned self] (text) in
                self.needRecordSearch = true
                var searchType = SearchType.cityName(text, self.filteredCountryCode.value)
                if let _ = UInt(text) {
                    searchType = SearchType.zipCode(text, self.filteredCountryCode.value)
                }

                return searchType
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .bind(to: jsonFeedAction.inputs)
            .disposed(by: disposeBag)

        input.countryCodeUpdate
            .bind(to: filteredCountryCode)
            .disposed(by: disposeBag)

        input.gpsLocationTrigger
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .subscribe(onNext: {
                [unowned self] () in
                if self.networkConnected.value {
                    self.needRecordSearch = true
                    self.searchCurrentLocationWeather()
                } else {
                    self.serviceErrorTrigger.onNext(ServiceError.network)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        input.refreshWeather
            .subscribe(onNext: {
                [unowned self] (_) in
                self.needRecordSearch = false
                self.refreshLatestCityWeather()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func downloadServiceBinding() {
        let response = BehaviorRelay<WeatherCityData?>(value: nil)

        jsonFeedAction = Action {
            [unowned self] searchInput in
            self.downloadIndicatorTrigger.onNext(true)
            self.needSearchLocation = nil
            return self.weatherService.getCityWetherData(searchType: searchInput, appId: nil)
        }

        jsonFeedAction.elements
            .bind(to: response)
            .disposed(by: disposeBag)

        jsonFeedAction.errors
        .debug()
            .subscribe(onNext: {
                [unowned self] (actionError) in

                self.downloadIndicatorTrigger.onNext(false)
                self.serviceErrorTrigger.onNext(ServiceError.notFound)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        //Record jsonFeed data
        response
        .filter { $0 != nil }
        .subscribe(onNext: {
            [unowned self] (weatherData) in
                self.setupDataSource(cityWeatherData: weatherData!)
                self.savedLatestWeatherCity.savedWeatherData = weatherData!
                self.savedLatestWeatherTime.value = Date()
                self.recordSearchHistory(weatherData: weatherData!)
                debugPrint("Download suc to drive downloadIndicatorTrigger false")
                self.weatherDataRefreshTrigger.onNext(())
                self.downloadIndicatorTrigger.onNext(false)
            },
            onError: {
                [unowned self] (serviceError) in

                debugPrint("Download faild by city not found: \(serviceError.localizedDescription)")
                self.serviceErrorTrigger.onNext(ServiceError.notFound)
                self.downloadIndicatorTrigger.onNext(false)
            },
            onCompleted: nil,
            onDisposed: nil)
        .disposed(by: disposeBag)
    }

    private func locationServiceBinding() {
        locationService.output?.locationData
            .subscribe(onNext: {
                [unowned self] (lat, lon) in
                self.fetchWeatherDataByLocation(lat: lat, lon: lon)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        locationService.output?.error
            .subscribe(onNext: {
                [unowned self] (serviceError) in
                self.downloadIndicatorTrigger.onNext(false)
                self.serviceErrorTrigger.onNext(serviceError)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func networkBinding() {
        networkMonitor.output?.networkConnected
            .distinctUntilChanged()
            .bind(to: networkConnected)
            .disposed(by: disposeBag)

        self.networkConnected
            .share()
            .filter {
                [unowned self] (isConnected) in
                return (self.needSearchLocation != nil) && isConnected
            }
            .subscribe(onNext: {
                [unowned self] _ in
                self.needRecordSearch = false
                debugPrint("Auto search loction weather by network recovery")
                self.searchCityTrigger.onNext(self.needSearchLocation!)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func initLoadBinding() {
        countryCodeDecoder.initSetup()
        locationService.input.authorizationCheckTrigger.onNext(())

        networkMonitor.input.triggerMonitor.onNext((true))
    }

    func loadSavedWeatherData() {
        guard let latestSavedWeatherData = self.savedLatestWeatherCity.savedWeatherData else {
            return
        }

        setupDataSource(cityWeatherData: latestSavedWeatherData)
        weatherDataRefreshTrigger.onNext(())
    }

    private func setupDataSource(cityWeatherData: WeatherCityData) {
        dataSource.removeAll()

        dataSource.append(WeatherDetailType.sunTime((cityWeatherData.sys?.sunrise ?? 0), (cityWeatherData.sys?.sunset ?? 0)))
        dataSource.append(WeatherDetailType.description(cityWeatherData.weather?.first?.description ?? ""))
        dataSource.append(WeatherDetailType.temperature("\(cityWeatherData.main?.tempMin ?? 0)°C --- \(cityWeatherData.main?.tempMax ?? 0)°C"))
        dataSource.append(WeatherDetailType.wind(String(cityWeatherData.wind?.speed ?? 0)))
        dataSource.append(WeatherDetailType.humidity(String(cityWeatherData.main?.humidity ?? 0)))
    }

    private func recordSearchHistory(weatherData: WeatherCityData) {
        guard needRecordSearch else {
            return
        }

        var searchCity = CityInfo()
        searchCity.country = weatherData.sys?.country ?? ""
        searchCity.name = weatherData.name ?? ""
        searchCity.id =  weatherData.id
        searchCity.state = ""
        searchCity.lat = weatherData.coord?.lat
        searchCity.lon = weatherData.coord?.lon

        debugPrint("record Search by cityName: \(searchCity.name), cityId: \(searchCity.id)")

        var savedRecords = self.savedRecentSearch.savedSearchCities
        savedRecords.insert(searchCity, at: 0)
        self.savedRecentSearch.savedSearchCities = savedRecords
    }

    private func searchCurrentLocationWeather() {
        if locationService.isLocationAllowed {
            self.downloadIndicatorTrigger.onNext(true)
            self.locationService.input.requestLocationUpdate.onNext(())
        } else {
            self.serviceErrorTrigger.onNext(ServiceError.gpsError)
        }
    }

    private func fetchWeatherDataByLocation(lat: Double, lon: Double) {
        let latStr = String(format: "%.4f", lat)
        let lonStr = String(format: "%.4f", lon)
        self.searchCityTrigger.onNext(.location(latStr, lonStr))
    }

    private func refreshLatestCityWeather() {
        guard let latestSavedWeatherData = self.savedLatestWeatherCity.savedWeatherData else {
            return
        }

        var searchType: SearchType?
        if latestSavedWeatherData.id != nil &&  latestSavedWeatherData.id! > 0 {
            searchType = SearchType.cityId(String(latestSavedWeatherData.id!))
        } else if latestSavedWeatherData.coord != nil && latestSavedWeatherData.coord!.lat != nil
            && latestSavedWeatherData.coord!.lon != nil {
            let latStr = String(format: "%.4f", latestSavedWeatherData.coord!.lat!)
            let lonStr = String(format: "%.4f", latestSavedWeatherData.coord!.lon!)
            searchType = SearchType.location(latStr, lonStr)
        } else if latestSavedWeatherData.name != nil && !latestSavedWeatherData.name!.isEmpty && !latestSavedWeatherData.name!.contains(" ")
        && latestSavedWeatherData.sys?.country != nil && !latestSavedWeatherData.sys!.country!.isEmpty {
            searchType = SearchType.cityName(latestSavedWeatherData.name!, latestSavedWeatherData.sys!.country!)
        }

        if searchType != nil {
            self.searchCityTrigger.onNext(searchType!)
        }
    }
}

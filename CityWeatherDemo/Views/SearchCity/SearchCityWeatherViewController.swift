//
//  SearchCityWeatherViewController.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 29/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxAppState

class SearchCityWeatherViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var filteredCountry: PickerTextField!
    @IBOutlet weak var flagLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    
    private let recentSearchSegue = "recentSearchSegue"
    
    var viewModel: SearchCityWeatherProtocol?
    private let disposeBag = DisposeBag()
    private var isPickerDisplay = false
    
    private var gpsButton: UIBarButtonItem!
    private var recentSearchBarButton: UIBarButtonItem!
    private var refreshButton: UIBarButtonItem!
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private var activityBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        flagLabel.text = "AU".getFlag()
        filteredCountry.text = "AU"
        filterButton.isEnabled = false
        filteredCountry.isUserInteractionEnabled = false
        activityIndicator.sizeToFit()
        activityIndicator.color = self.view.tintColor
        activityBarButton = UIBarButtonItem(customView: activityIndicator)
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: nil)
        gpsButton = UIBarButtonItem(image: UIImage(named: "gps"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItems = [refreshButton, gpsButton]
        
        recentSearchBarButton = UIBarButtonItem(image: UIImage(named: "history"), style: .plain, target: self, action: nil)
        self.navigationItem.setLeftBarButton(recentSearchBarButton, animated: false)
        
        tableViewSetup()
        setupSearchBar()
        viewModelBinding()
    }

    private func tableViewSetup() {
        self.tableView.separatorStyle = .singleLine
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = 60
        self.tableView.backgroundColor = Appearance.Style.Colors.tableViewGroupBackground
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let sectionViewNib = UINib(nibName: TopHeaderSectionView.identifier, bundle: nil)
        tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: TopHeaderSectionView.identifier)
        self.tableView.register(SunriseSunsetTableViewCell.nib, forCellReuseIdentifier: SunriseSunsetTableViewCell.identifier)
        self.tableView.register(CityDetailTableViewCell.nib, forCellReuseIdentifier: CityDetailTableViewCell.identifier)
    }
    
    private func setupPickerTextField() {
        guard self.viewModel?.countryList != nil else {
            return
        }
        
        self.filteredCountry.textColor = Appearance.Style.Colors.label
        self.filteredCountry.delegate = self
        let defaultCountryCode = "AU"
        self.flagLabel.text = defaultCountryCode.getFlag()
        self.filteredCountry.configurePicker(defaultText: defaultCountryCode, itemList: self.viewModel!.countryList) {
            [unowned self] (index) in
            guard index < self.viewModel!.countryList.count else {
                return
            }
            
            let selectedCountryCode = self.viewModel!.countryList[index]
            debugPrint("Selected Country: \(selectedCountryCode)")
            self.flagLabel.text = selectedCountryCode.getFlag()
            self.viewModel?.input.countryCodeUpdate
                .onNext(selectedCountryCode)
        }
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func viewModelBinding() {
        guard viewModel?.output != nil else {
            return
        }
        
        viewModel?.output?.refreshTableView
            .skipUntil(rx.viewDidAppear)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (date) in
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        viewModel?.output?.isLoading
            .skipUntil(rx.viewDidAppear)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (startLoadingNewData) in
                    if startLoadingNewData {
                        self.view.endEditing(true)
                        self.showRefreshing()
                    } else {
                        //SVProgressHUD.dismiss()
                        self.hideRefreshing()
                    }
                
                    self.filterButton.isUserInteractionEnabled = !startLoadingNewData
                    self.searchBar.isUserInteractionEnabled = !startLoadingNewData
                
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        viewModel?.output?.presentRecentSearch
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] savedCitiesArray in
                self.view.endEditing(true)
                self.filteredCountry.text = ""
                self.performSegue(withIdentifier: self.recentSearchSegue, sender: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        viewModel?.output?.countryCodeDone
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (isEnabled) in
                if isEnabled {
                    self.setupPickerTextField()
                    self.filterButton.isEnabled = true
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        viewModel?.output?.error
            .skipUntil(rx.viewDidAppear)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (serviceError) in
                self.alertServiceError(error: serviceError)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        //UIButton rx binding
        refreshButton.rx.tap
            .bind(to: viewModel!.input.refreshWeather)
            .disposed(by: disposeBag)
        
        gpsButton.rx.tap
            .bind(to: viewModel!.input.gpsLocationTrigger)
            .disposed(by: disposeBag)
        
        recentSearchBarButton.rx.tap.bind(to: viewModel!.input.recentSearchView)
            .disposed(by: disposeBag)
        
        filterButton.rx.tap
            .subscribe(onNext: {
                [unowned self] (_) in
                self.filterButtonTapped()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        //First launch load most recent weather data.
        rx.viewDidAppear
        .take(1)
        .subscribe(onNext: {
            [unowned self] (_) in
            debugPrint("SearchCityWeather viewDidAppear")
            self.viewModel?.loadSavedWeatherData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
    }
    
    private func filterButtonTapped() {
        guard !isPickerDisplay else {
            return
        }
        
        self.filteredCountry.isUserInteractionEnabled = true
        
        self.filteredCountry.becomeFirstResponder()
    }
    
    private func showRefreshing() {
        self.activityIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItems([activityBarButton, gpsButton], animated: true)
    }
    
    private func hideRefreshing() {
        self.activityIndicator.stopAnimating()
        self.navigationItem.setRightBarButtonItems([refreshButton, gpsButton], animated: true)
    }
    
    private func alertServiceError(error: ServiceError) {
        let alertController = UIAlertController(title: "Alert-Title".localized,
                                                message: "NotFount-Message".localized,
                                                preferredStyle: .alert)

        let okayButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        alertController.addAction(okayButton)
        self.present(alertController, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recentSearchSegue {
            if let subNavVC = segue.destination as? UINavigationController,
                let recentSearchVC = subNavVC.topViewController as? RecentSearchCityViewController {
                recentSearchVC.viewModel = RecentSearchViewModel()
                if #available(iOS 13.0, *) {
                    recentSearchVC.isModalInPresentation = true
                }
            }
        }
    }
}

extension SearchCityWeatherViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isPickerDisplay = true
        self.searchBar.text = ""
        self.searchBar.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isPickerDisplay = false
        self.filteredCountry.isUserInteractionEnabled = false
        self.searchBar.isUserInteractionEnabled = true
    }
}

extension SearchCityWeatherViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != nil && !searchBar.text!.isEmpty else {
            return
        }
        
        debugPrint("search text: \(searchBar.text!)")
        self.viewModel?.input.searchContentTrigger
            .onNext(searchBar.text!)
        searchBar.resignFirstResponder()
    }
}

extension SearchCityWeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.dataSource.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.viewModel != nil && indexPath.row < self.viewModel!.dataSource.count else {
                return UITableViewCell()
        }
            
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SunriseSunsetTableViewCell.identifier, for: indexPath) as? SunriseSunsetTableViewCell {
                let cellData = self.viewModel!.dataSource[indexPath.row]
                cell.config(sunrise: TimeInterval(cellData.sunTimeData().0), sunset: TimeInterval(cellData.sunTimeData().1))
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: CityDetailTableViewCell.identifier, for: indexPath) as? CityDetailTableViewCell {
            let cellData = self.viewModel!.dataSource[indexPath.row]
            cell.config(cellData: cellData)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopHeaderSectionView.identifier) as? TopHeaderSectionView,
             self.viewModel != nil, let latestWeatherData = self.viewModel!.latestWeatherData else {
                return UIView()
        }
        
        sectionView.config(refreshTime: self.viewModel!.dataUpdateTime, cityName: latestWeatherData.name ?? "", countryCode: latestWeatherData.sys?.country ?? "")
        return sectionView
    }
}

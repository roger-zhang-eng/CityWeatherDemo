//
//  RecentSearchCityViewController.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxAppState

class RecentSearchCityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var cancelButton: UIBarButtonItem!
    private var deleteAllButton: UIBarButtonItem!
    
    var viewModel: RecentSearchProtocol?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        deleteAllButton = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: nil)
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        self.navigationItem.setRightBarButton(deleteAllButton, animated: false)
        
        self.title = "RecentSearchView-Title".localized
        tableViewSetup()
        viewModelBinding()
    }

    private func tableViewSetup() {
        self.tableView.separatorStyle = .singleLine
        self.tableView.rowHeight = 52
        self.tableView.backgroundColor = Appearance.Style.Colors.tableViewGroupBackground
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.register(RecentSearchHeaderView.self, forHeaderFooterViewReuseIdentifier: RecentSearchHeaderView.identifier)
        self.tableView.register(RecentSearchTableViewCell.nib, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)
    }
    
    func viewModelBinding() {
        guard viewModel?.output != nil else {
            return
        }
        
        viewModel?.output?.refreshTableView
            .skipUntil(rx.viewDidAppear)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (_) in
                debugPrint("refresh tableView")
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        viewModel?.output?.needConfirmDeleteAll
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (_) in
                self.alertToConfirmDeleteAll()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        viewModel?.output?.dismissView
            .skipUntil(rx.viewDidAppear)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (_) in
                self.dismiss(animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel!.input.viewDismiss)
            .disposed(by: disposeBag)
        
        deleteAllButton.rx.tap
            .bind(to: viewModel!.input.deleteAllTrigger)
            .disposed(by: disposeBag)
        
        //First launch load tableView.
        rx.viewDidAppear
        .take(1)
        .subscribe(onNext: {
            [unowned self] (_) in
            debugPrint("RecentSearch viewDidAppear")
            self.viewModel?.input.refreshDataSourceTrigger.onNext(())
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
    }
    
    private func alertToConfirmDeleteAll() {
        let alertController = UIAlertController(title: "Alert-Title".localized,
                                                message: "DeleteAll-Message".localized,
                                                preferredStyle: .alert)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueButton = UIAlertAction(title: "Continue", style: .destructive) {
            [unowned self] (_) in
            self.viewModel?.input.deleteAllConfirm.onNext(())
        }
        
        alertController.addAction(cancelButton)
        alertController.addAction(continueButton)
        self.present(alertController, animated: true, completion: nil)
    }
}


extension RecentSearchCityViewController: UITableViewDataSource, UITableViewDelegate {
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
            
        if let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchTableViewCell.identifier, for: indexPath) as? RecentSearchTableViewCell {
            let cellData = self.viewModel!.dataSource[indexPath.row]
            cell.config(countryCode: cellData.country ?? "", cityName: cellData.name ?? "")
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel != nil && indexPath.row < viewModel!.dataSource.count else {
            return
        }
        
        self.viewModel!.input.presentCityWeather.onNext(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard viewModel != nil && indexPath.row < viewModel!.dataSource.count else {
            return
        }
        
        if editingStyle == .delete {
            self.viewModel!.input.deleteCellItem.onNext(indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecentSearchHeaderView.identifier) as! RecentSearchHeaderView

       return view
    }
}

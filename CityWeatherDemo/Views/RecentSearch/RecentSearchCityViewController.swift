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

    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var cancelButton: UIBarButtonItem!
    //private var deleteAllButton: UIBarButtonItem!
    
    private var editButton: UIBarButtonItem!
    private var deleteButton: UIBarButtonItem!
    
    var viewModel: RecentSearchProtocol?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: nil)
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        self.navigationItem.setRightBarButton(editButton, animated: false)
        
        self.title = "RecentSearchView-Title".localized
        self.indicatorLabel.text = "RecentSearchView-Indicate".localized
        self.indicatorLabel.textColor = Appearance.Style.Colors.label
        
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
        
        viewModel?.output?.dismissView
            .skipUntil(rx.viewDidAppear)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (_) in
                self.dismiss(animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        viewModel?.output?.updateDisplay
            .skipUntil(rx.viewDidAppear)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (_) in
                self.updateDisplay()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        viewModel?.output?.updateDeleteNumber
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {
            [unowned self] (number) in
            self.indicatorLabel.text = "(" + String(number) + ") Selected"
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        viewModel?.output?.editModeTableViewCellCheckStateSwitchTriger
            .delay(0.4, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] (indexPath) in
                self.editModeTableViewCellSwitchCheckState(indexPath: indexPath)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel!.input.cancelTrigger)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .bind(to: viewModel!.input.editModeTrigger)
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind(to: viewModel!.input.deleteTrigger)
            .disposed(by: disposeBag)
        
        //First launch load tableView.
        rx.viewDidAppear
        .take(1)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {
            [unowned self] (_) in
            debugPrint("RecentSearch viewDidAppear")
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
    }
    
    private func updateDisplay() {
        guard viewModel != nil else {
            return
        }
        
        if viewModel!.isEditMode {
            self.navigationItem.setLeftBarButton(deleteButton, animated: true)
            self.navigationItem.setRightBarButton(cancelButton, animated: true)
            self.indicatorLabel.text = "(0) Selected"
        } else {
            self.navigationItem.setLeftBarButton(cancelButton, animated: true)
            self.navigationItem.setRightBarButton(editButton, animated: true)
            self.indicatorLabel.text = "RecentSearchView-Indicate".localized
        }
        
        updateVisibleTableViewCell(isEditMode: viewModel!.isEditMode)
    }
    
    private func updateVisibleTableViewCell(isEditMode: Bool) {
        if let visibleCells = tableView.visibleCells as? [RecentSearchTableViewCell] {
            for cell in visibleCells {
                cell.switchMode(isEditMode: isEditMode)
            }
        }
    }
    
    private func editModeTableViewCellSwitchCheckState(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
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
            cell.config(countryCode: cellData.country ?? "",
                        cityName: cellData.name ?? "",
                        isEditMode: viewModel!.isEditMode,
                        isChecked: viewModel!.deleteIndexSet.contains(indexPath.row))
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel != nil && indexPath.row < viewModel!.dataSource.count else {
            return
        }
        
        self.viewModel!.input.selectCellItem.onNext(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

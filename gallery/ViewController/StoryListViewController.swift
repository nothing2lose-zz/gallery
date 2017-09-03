//
//  StoryListViewController.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import CoreStore

final class StoryListViewController: UIViewController, CameraViewControllerDelegate {
    
    fileprivate lazy var textfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "검색어를 입력해주세요."
        let close = KeyboardResignAccessoryView()
        close.textfield = tf
        return tf
    }()
    fileprivate lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.register(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tb.allowsMultipleSelectionDuringEditing = false
        tb.allowsMultipleSelection = false
        tb.dataSource = self
        tb.delegate = self
        return tb
    }()
    private var disposeBag = DisposeBag()
    
    var items: [[Story]] = []
    
    
    // MARK: - lifecycle
    deinit {
        Storage.stories.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CaptureSessionManager.requestAccess()
        
        // initialise CoreData
        Storage.initialize()
        
        // add observer for CoreStore
        Storage.stories.addObserver(self)
        
        // ui & event binding
        setup()
    }
    
    // MARK: - private
    private func setup() {
        
        view.backgroundColor = .white
        
        // layout
        
        view.addSubview(textfield)
        view.addSubview(tableView)
        
        textfield.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.height.equalTo(40)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(textfield.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        // event binding
        textfield.rx.text.orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { (text) in
                Storage.filter = text.isEmpty ? .all : .query(query: text)
            }
            .addDisposableTo(disposeBag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(onNext: { [weak self] () in
                guard let `self` = self else { return }
                self.addStory()
            })
            .addDisposableTo(disposeBag)
        
        // style
        tableView.rowHeight = 101
        title = "Story"
        
    }
    
    fileprivate func updateTitle() {
        navigationItem.title = "Story (\(Storage.numberOfStories))"
    }
    
    private func addStory() {
        let vc = CameraViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    private func createStory(images: [UIImage]) {
        let vc = StoryAddViewController()
        vc.images = images
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func setTable(enabled: Bool) {
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { () -> Void in
                self.tableView.alpha = enabled ? 1.0 : 0.5
                self.tableView.isUserInteractionEnabled = enabled
        },
            completion: nil
        )
    }
    
    
    // MARK: - CameraViewControllerDelegate
    func cameraViewController(viewController: CameraViewController, didConfirmWith images: [UIImage]) {
        if images.count > 0 {
            createStory(images: images)
        }
    }
    func cameraViewControllerDidCancel() {}
    
    
    
}

extension StoryListViewController: ListSectionObserver {
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<Story>) {
        
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Story>) {
        updateTitle()
        self.tableView.endUpdates()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Story>) {
        
        self.setTable(enabled: false)
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Story>) {
        updateTitle()
        self.tableView.reloadData()
        self.setTable(enabled: true)
    }
    
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<Story>, didInsertObject object: Story, toIndexPath indexPath: IndexPath) {
        
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Story>, didDeleteObject object: Story, fromIndexPath indexPath: IndexPath) {
        
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Story>, didUpdateObject object: Story, atIndexPath indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? StoryCell {
            cell.viewModel = StoryViewModel(Storage.stories[indexPath])
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<Story>, didMoveObject object: Story, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
        self.tableView.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<Story>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    
    func listMonitor(_ monitor: ListMonitor<Story>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }

}

// MARK: - UITableView DataSource & Delegate
extension StoryListViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // MARK: datasource
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Storage.deleteStory(Storage.stories[indexPath], nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Storage.stories.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.stories.numberOfObjectsInSection(safeSectionIndex: section)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.identifier, for: indexPath) as? StoryCell else {
            return UITableViewCell()
        }
        cell.viewModel = StoryViewModel(Storage.stories[indexPath])
        return cell
    }
    
    // MARK: delegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Storage.stories.sectionInfoAtIndex(section).name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = StoryDetailViewController()
        vc.viewModel = StoryViewModel(Storage.stories[indexPath])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textfield.resignFirstResponder()
    }
    
}

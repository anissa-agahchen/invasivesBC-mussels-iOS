//
//  WaterbodyPicker.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-06.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar
{
    func setPlaceholderTextColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
    
    func setMagnifyingGlassColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
}

class WaterbodyPicker: UIView, Theme {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var barContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var otherContainer: UIView!
    @IBOutlet weak var addManuallyButton: UIButton!
    
    // MARK: Constants
    private let tableCells = [
        "WaterbodyTableViewCell",
    ]
    
    private let collectionCells = [
        "SelectedWaterBodyCollectionViewCell",
    ]
    
    // MARK: Variables:
    private var items: [DropdownModel] = []
    private var filteredItems: [DropdownModel] = []
    private var completion: ((_ result: DropdownModel?) -> Void )?
    private var selections: [DropdownModel] = []
    
    deinit {
        print("de-init waterbodyPicker")
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    /**
     Displays Wateroicker in Container and returns DropdownModel Result
     */
    func setup(in containerView: UIView, result: @escaping(DropdownModel?) -> Void) {
        self.completion = result
        self.loadWaterBodies()
        self.position(in: containerView)
        self.style()
        self.setUpTable()
        self.setupCollectionView()
        self.searchBar.delegate = self
        self.tableView.reloadData()
    }
    
    // Return Results
    private func returnResult(item: DropdownModel){
        guard let callback = self.completion else {return}
        return callback(item)
    }
    
    private func selected(item: DropdownModel) {
        if indexOf(selection: item) != nil {
            remove(item: item)
        } else {
            selections.append(item)
            self.collectionView.reloadData()
        }
    }
    
    private func remove(item: DropdownModel) {
        guard let index = indexOf(selection: item) else {return}
        self.selections.remove(at: index)
        self.collectionView.reloadData()
    }
    
    private func indexOf(selection: DropdownModel) -> Int? {
        for (index, value) in selections.enumerated() where selection.display == value.display && selection.key == value.key {
            return index
        }
        return nil
    }
    
    // Load all waterbodies from storage
    private func loadWaterBodies() {
        self.items = Storage.shared.getWaterBodyDropdowns()
        self.filteredItems = items
        self.otherContainer.alpha = 0
        self.tableView.alpha = 1
    }
    
    // Reset results to show all water bodies
    private func resetSearch() {
        self.filteredItems = self.items
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 1
            self.otherContainer.alpha = 0
            self.layoutIfNeeded()
        }
        self.tableView.reloadData()
    }
    
    // When user enters 'Other'
    private func showOtherDialog() {
        self.filteredItems = []
        self.tableView.reloadData()
        self.searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.otherContainer.alpha = 1
            self.tableView.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    // Filter Reaults
    private func filter(by text: String) {
        self.otherContainer.alpha = 0
        self.filteredItems = items.filter{$0.display.contains(text)}
        self.tableView.reloadData()
    }
    
    private func position(in containerView: UIView) {
        // Set initial position with 0 alpha and add as subview
        self.frame = CGRect(x: 0, y: containerView.frame.maxY, width: containerView.bounds.width, height: containerView.bounds.height)
        self.center.x = containerView.center.x
        self.alpha = 0
        containerView.addSubview(self)
        self.layoutIfNeeded()
        // Animate setting alpha to 1 and adding constraints to equal container's
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: CGFloat(0.5), options: .curveEaseInOut, animations: {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -20).isActive = true
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
            self.alpha = 1
            self.layoutIfNeeded()
        })
    }
    
    private func style() {
        self.barContainer.backgroundColor = Colors.primary
        self.backButton.setTitleColor(.white, for: .normal)
        self.selectButton.setTitleColor(.white, for: .normal)
        self.searchBar.barTintColor = Colors.primary
        self.titleLabel.textColor = UIColor.white
        searchBar.setPlaceholderTextColorTo(color: .white)
        searchBar.setMagnifyingGlassColorTo(color: .white)
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        styleFillButton(button: addManuallyButton)
    }
}

// MARK: Search Bar Delegate
extension WaterbodyPicker: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.resetSearch()
            return
        }
        if searchText.lowercased() == "other" {
            self.showOtherDialog()
            return
        }
        
        self.filter(by: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
}

// MARK: TableView
extension WaterbodyPicker: UITableViewDataSource, UITableViewDelegate {
    private func setUpTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        for cell in tableCells {
            register(table: cell)
        }
    }
    
    func register(table cellName: String) {
        let nib = UINib(nibName: cellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellName)
    }
    
    func getRowCell(indexPath: IndexPath) -> WaterbodyTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "WaterbodyTableViewCell", for: indexPath) as! WaterbodyTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getRowCell(indexPath: indexPath)
        cell.setup(item: filteredItems[indexPath.row], onClick: {
            self.selected(item: self.filteredItems[indexPath.row])
        })
        
        return cell
    }
}

// MARK: CollectionView
extension WaterbodyPicker: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        guard let collectionView = self.collectionView else {return}
        for cell in collectionCells {
            register(collection: cell)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.layoutd
    }
    
    func register(collection cellName: String) {
        guard let collectionView = self.collectionView else {return}
        let nib = UINib(nibName: cellName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellName)
    }
    
    func getSelectedCell(indexPath: IndexPath) -> SelectedWaterBodyCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "SelectedWaterBodyCollectionViewCell", for: indexPath as IndexPath) as! SelectedWaterBodyCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getSelectedCell(indexPath: indexPath)
        cell.setup(item: selections[indexPath.row]) {
            self.remove(item: self.selections[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = selections[indexPath.row]
        let textWidth = item.display.width(withConstrainedHeight: self.collectionView.bounds.height, font: Fonts.getPrimary(size: 17))
        let buttonWidth: CGFloat = 35
        let padding: CGFloat = 32
        return CGSize(width: textWidth + buttonWidth + padding, height: 60)
    }
    
}

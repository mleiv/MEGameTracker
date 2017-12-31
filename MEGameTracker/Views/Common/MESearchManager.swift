//
//  MESearchManager.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/8/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class MESearchManager: NSObject {

	// passed in
	private var controller: UIViewController
	private var tempSearchBar: UISearchBar?
	// - (optional)
	private var resultsController: UITableViewController?
	private var searchData: ((_ needle: String?) -> Void) = { _ in }
	private var closeSearch: (() -> Void) = { }

	// revealed
	public var searchController: UISearchController?
	public var showSearchData: Bool = false

	// interal use only
	private var lastSearch: String = ""

	public init(
		controller: UIViewController,
		tempSearchBar: UISearchBar? = nil,
		resultsController: UITableViewController? = nil,
		searchData: ((_ needle: String?) -> Void)? = nil,
		closeSearch: (() -> Void)? = nil
	) {
		self.controller = controller
		self.tempSearchBar = tempSearchBar
		self.resultsController = resultsController
		super.init()
		self.searchData = searchData ?? self.searchData
		self.closeSearch = closeSearch ?? self.closeSearch
		setupSearchController()
	}

	public func reloadData() {
		(searchController?.searchResultsController as? UITableViewController)?.tableView?.reloadData()
	}

	public func styleSearchTable(_ closure: (UITableView?) -> Void ) {
		closure((searchController?.searchResultsController as? UITableViewController)?.tableView)
	}

	private func setupSearchController() {
		controller.definesPresentationContext = true // hold search to our current bounds
		// create search controller (no IB equivalent)
		let searchController = UISearchController(searchResultsController: resultsController)
        searchController.hidesNavigationBarDuringPresentation = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchResultsUpdater = self
		searchController.searchBar.delegate = self
		searchController.searchBar.searchBarStyle = tempSearchBar?.searchBarStyle
			?? searchController.searchBar.searchBarStyle
		searchController.searchBar.placeholder = tempSearchBar?.placeholder
		searchController.searchBar.barTintColor = tempSearchBar?.barTintColor
		// fix the black line:
//		searchController.searchBar.layer.borderWidth = CGFloat(1)/UIScreen.mainScreen().scale //1px
//		searchController.searchBar.layer.borderColor = tempSearchBar?.barTintColor?.CGColor
		// replace placeholder:
		searchController.searchBar.setNeedsLayout()
		searchController.searchBar.layoutIfNeeded()
		self.searchController = searchController
//        TODO: fix the excess header between search bar and results.
//        Below is icky and doesn't work well on horizontal/ipad
//        if #available(iOS 10.0, *) {
//            resultsController?.automaticallyAdjustsScrollViewInsets = false
//            resultsController?.tableView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0)
//        }
	}
}

// MARK: UISearchResultsUpdating protocol
extension MESearchManager: UISearchResultsUpdating {

	public func updateSearchResults(for searchController: UISearchController) {
		let search = searchController.searchBar.text?.trim() ?? ""
		if search.isEmpty && !lastSearch.isEmpty {
			lastSearch = ""
			searchData(nil)
		} else if !search.isEmpty && search != lastSearch {
			lastSearch = search
			showSearchData = true
			searchData(search)
//			searchController.active = true
		}
	}

}

// MARK: UISearchBarDelegate protocol
extension MESearchManager: UISearchBarDelegate {

	public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		if searchController?.isActive == true {
			lastSearch = ""
			showSearchData = false
			searchController?.dismiss(animated: true) { () -> Void in }
			closeSearch()
		}
	}
}

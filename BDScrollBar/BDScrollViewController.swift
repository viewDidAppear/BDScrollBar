//
//  BDScrollViewController.swift
//  BDScrollBar
//
//  Created by Benjamin Deckys on 2022/05/13.
//

import UIKit

class BDScrollViewController: UITableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		let scrollBar = BDScrollBar(style: .modern)
		self.tableView.bd_addScrollBar(scrollBar)
		self.tableView.separatorInset = scrollBar.adjustedSeparatorInsets(for: self.tableView.separatorInset)
		self.tableView.backgroundColor = .white
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		100
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var listConfig = UIListContentConfiguration.cell()
		listConfig.textProperties.color = .black
		listConfig.text = String(format: "Cell %ld", indexPath.row)

		let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
		cell.contentConfiguration = listConfig
		cell.layoutMargins = tableView.bd_scrollBar?.adjustedCellLayoutMargins(for: cell.layoutMargins) ?? cell.layoutMargins
		cell.accessoryType = .disclosureIndicator

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		44
	}

}


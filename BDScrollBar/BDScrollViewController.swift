//
//  BDScrollViewController.swift
//  BDScrollBar
//
//  Created by Benjamin Deckys on 2022/05/13.
//

import UIKit

class BDScrollViewController: UITableViewController {

	private lazy var scrollBar: BDScrollBar = {
		BDScrollBar() // BDScrollBar(style: .modern)
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.bd_addScrollBar(scrollBar)
		tableView.separatorInset = scrollBar.adjustedSeparatorInsets(for: tableView.separatorInset)
	}

}

extension BDScrollViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var listConfig = UIListContentConfiguration.cell()
		listConfig.textProperties.color = UIColor(named: "Text")!
		listConfig.text = String(format: "Cell %ld", indexPath.row)

		let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
		cell.contentConfiguration = listConfig
		cell.layoutMargins = tableView.bd_scrollBar?.adjustedCellLayoutMargins(for: cell.layoutMargins) ?? cell.layoutMargins
		cell.accessoryType = .disclosureIndicator

		return cell
	}
}

extension BDScrollViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		100
	}
}

extension BDScrollViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension BDScrollViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		44
	}
}

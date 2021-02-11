////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DataDonationViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, DismissHandling {
	
	// MARK: - Init
	init(
		store: Store,
		presentSelectValueList: @escaping (SelectValueViewModel) -> Void,
		didTapLegal: @escaping () -> Void
	) {
		self.presentSelectValueList = presentSelectValueList
		self.didTapLegal = didTapLegal

		guard let url = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			preconditionFailure("missing json file")
		}
		let datadonationModel = DataDonationModel(
			store: store,
			jsonFileURL: url
		)

		self.viewModel = DataDonationViewModel(
			store: store,
			presentSelectValueList: presentSelectValueList,
			datadonationModel: datadonationModel
		)

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
	}
	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.DataDonation.Info.buttonOK
		item.isPrimaryButtonEnabled = true
		
		item.secondaryButtonTitle = AppStrings.DataDonation.Info.buttonNOK
		item.secondaryButtonHasBackground = true
		item.isSecondaryButtonHidden = false
		item.isSecondaryButtonEnabled = true

		// item.title = AppStrings.DataDonation.Info.title

		return item
	}()
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save(consentGiven: true)
		finished?()
	}
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		viewModel.save(consentGiven: false)
		finished?()
	}

	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		
	}

	// MARK: - Public

	// MARK: - Internal
	
	var finished: (() -> Void)?

	// MARK: - Private
	private let presentSelectValueList: (SelectValueViewModel) -> Void
	private let didTapLegal: () -> Void

	private let viewModel: DataDonationViewModel
	private var subscriptions: [AnyCancellable] = []

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel

		viewModel.$reloadTableView
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.dynamicTableViewModel = self.viewModel.dynamicTableViewModel
				self.tableView.reloadData()
			}.store(in: &subscriptions)
	}
}

// MARK: - Cell reuse identifiers.

extension DataDonationViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
		case legalExtended = "DynamicLegalExtendedCell"
	}
}
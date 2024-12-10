import ComposableArchitecture
import UIKit

@Reducer
struct FeatureC: Reducer {
	struct State: Equatable {}

	enum Action {
		case buttonClicked
	}

	@Dependency(\.dismiss) var dismiss

	var body: some ReducerOf<Self> {
		Reduce { _, action in
			switch action {
			case .buttonClicked:
				return .run { _ in
					await dismiss()
				}
			}
		}
	}
}

class ViewControllerC: UIViewController {
	var store: StoreOf<FeatureC>

	private var button = UIButton(type: .system)

	init(store: StoreOf<FeatureC>) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .yellow

		button.frame = .init(x: 10, y: 100, width: view.frame.width - 20, height: 44)
		button.setTitle("Close", for: .normal)
		button.addAction(
			UIAction { [weak self] _ in self?.store.send(.buttonClicked) },
			for: .touchUpInside
		)
		view.addSubview(button)
	}
}

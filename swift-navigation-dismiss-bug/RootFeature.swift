import ComposableArchitecture
import UIKit

@Reducer
struct RootFeature: Reducer {
	@ObservableState
	struct State: Equatable {
		@Presents var destination: Destination.State?
	}

	enum Action {
		case destination(PresentationAction<Destination.Action>)
		case buttonClicked
	}

	@Reducer
	enum Destination {
		case featureA(FeatureA)
	}

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .destination:
				return .none

			case .buttonClicked:
				state.destination = .featureA(FeatureA.State())
				return .none
			}
		}
		.ifLet(\State.$destination, action: \Case<Action>.destination)
	}
}

extension RootFeature.Destination.State: Equatable {}

class ViewController: UIViewController {
	@UIBindable var store: StoreOf<RootFeature>

	private var button = UIButton(type: .system)

	required init?(coder: NSCoder) {
		let store = Store(initialState: RootFeature.State(), reducer: RootFeature.init)
		self.store = store
		super.init(coder: coder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white

		button.frame = .init(x: 10, y: 100, width: view.frame.width - 20, height: 44)
		button.setTitle("Present A", for: .normal)
		button.addAction(
			UIAction { [weak self] _ in self?.store.send(.buttonClicked) },
			for: .touchUpInside
		)
		view.addSubview(button)

		present(
			item: $store.scope(
				state: \.destination?.featureA,
				action: \.destination.featureA
			)
		) {
			ViewControllerD(store: $0)
		}
	}
}

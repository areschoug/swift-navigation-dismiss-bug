import ComposableArchitecture
import UIKit

@Reducer
struct FeatureA: Reducer {
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
		case featureB(FeatureB)
		case featureC(FeatureC)
	}

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .destination(.presented(.featureB(.buttonClicked))):
				state.destination = .featureC(.init())
				return .none

			case .destination:
				return .none

			case .buttonClicked:
				state.destination = .featureB(FeatureB.State())
				return .none
			}
		}
		.ifLet(\State.$destination, action: \Case<Action>.destination)
	}
}

extension FeatureA.Destination.State: Equatable {}

class ViewControllerD: UIViewController {
	@UIBindable var store: StoreOf<FeatureA>

	private var button = UIButton(type: .system)

	init(store: StoreOf<FeatureA>) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white

		button.frame = .init(x: 10, y: 100, width: view.frame.width - 20, height: 44)
		button.setTitle("Present B", for: .normal)
		button.addAction(
			UIAction { [weak self] _ in self?.store.send(.buttonClicked) },
			for: .touchUpInside
		)
		view.addSubview(button)

		present(
			item: $store
				.scope(
					state: \.destination?.featureB,
					action: \.destination.featureB
				)
		) {
			ViewControllerB(store: $0)
		}

		present(
			item: $store
				.scope(
					state: \.destination?.featureC,
					action: \.destination.featureC
				)
		) {
			ViewControllerC(store: $0)
		}
	}
}

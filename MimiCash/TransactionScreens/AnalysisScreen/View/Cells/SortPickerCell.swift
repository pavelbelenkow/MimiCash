import UIKit

final class SortPickerCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "SortPickerCell"
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl()
    
    // MARK: - Private Properties
    private var onSortChanged: ((TransactionsSort) -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(
        sort: TransactionsSort,
        onSortChanged: @escaping (TransactionsSort) -> Void
    ) {
        segmentedControl.selectedSegmentIndex = TransactionsSort.allCases.firstIndex(of: sort) ?? 0
        self.onSortChanged = onSortChanged
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        setupTitleLabel()
        setupSegmentedControl()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = Spec.Text.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupSegmentedControl() {
        TransactionsSort.allCases.enumerated().forEach { index, sort in
            segmentedControl.insertSegment(withTitle: sort.rawValue, at: index, animated: false)
        }
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        contentView.addSubview(segmentedControl)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spec.Layout.horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spec.Layout.horizontalPadding),
            segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: Spec.Layout.segmentedControlWidth)
        ])
    }
    
    @objc private func sortChanged() {
        let selectedSort = TransactionsSort.allCases[segmentedControl.selectedSegmentIndex]
        onSortChanged?(selectedSort)
    }
}

// MARK: - Spec
private enum Spec {
    enum Text {
        static let title = "Сортировка"
    }
    
    enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let segmentedControlWidth: CGFloat = 180
    }
}

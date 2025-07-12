import UIKit

final class SectionHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    static let identifier = "SectionHeaderView"
    
    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with title: String) {
        var content = defaultContentConfiguration()
        content.text = title
        content.textProperties.font = .systemFont(ofSize: Spec.Font.titleSize)
        content.textProperties.color = .secondaryLabel
        content.textProperties.alignment = .natural
        content.directionalLayoutMargins = Spec.Layout.margins
        
        contentConfiguration = content
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundConfiguration?.backgroundColor = .clear
    }
}

// MARK: - Spec
private enum Spec {
    enum Font {
        static let titleSize: CGFloat = 15
    }
    
    enum Layout {
        static let margins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 4,
            bottom: 8,
            trailing: 4
        )
    }
} 

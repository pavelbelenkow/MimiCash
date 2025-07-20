import UIKit
import PieChart

final class PieChartCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "PieChartCell"
    
    // MARK: - UI Components
    private let pieChartView = PieChart.createView(with: .spacious)
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with entities: [PieChartEntity]) {
        pieChartView.entities = entities
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pieChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pieChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pieChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
} 

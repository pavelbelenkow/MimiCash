import UIKit

final class DatePickerCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "DatePickerCell"
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let overlayView = UIView()
    private let dateLabel = UILabel()
    
    // MARK: - Private Properties
    private var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(title: String, date: Date, onDateChanged: @escaping (Date) -> Void) {
        titleLabel.text = title
        datePicker.date = date
        self.onDateChanged = onDateChanged
        updateDateLabel(date)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        setupTitleLabel()
        setupDatePicker()
        setupOverlayView()
        setupDateLabel()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .accent
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        contentView.addSubview(datePicker)
    }
    
    private func setupOverlayView() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .circle
        overlayView.layer.cornerRadius = Spec.Layout.overlayCornerRadius
        overlayView.isUserInteractionEnabled = false
        contentView.addSubview(overlayView)
    }
    
    private func setupDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: Spec.Font.dateLabelSize)
        dateLabel.textAlignment = .center
        dateLabel.isUserInteractionEnabled = false
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spec.Layout.horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spec.Layout.horizontalPadding),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spec.Layout.horizontalPadding),
            overlayView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: Spec.Layout.overlayWidth),
            overlayView.heightAnchor.constraint(equalToConstant: Spec.Layout.overlayHeight),
            
            dateLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])
    }
    
    private func updateDateLabel(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: date)
    }
    
    @objc private func dateChanged() {
        updateDateLabel(datePicker.date)
        onDateChanged?(datePicker.date)
    }
}

// MARK: - Spec
private enum Spec {
    
    enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let overlayCornerRadius: CGFloat = 6
        static let overlayWidth: CGFloat = 120
        static let overlayHeight: CGFloat = 32
    }
    
    enum Font {
        static let dateLabelSize: CGFloat = 16
    }
}

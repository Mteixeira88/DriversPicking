import UIKit

class DriverView: UIView {
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        
        return label
    }()
    
    var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        
        return label
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Assets.image(.locationPin)
        
        return imageView
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(dateLabel)
        
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(labelStackView)
        
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        
        stackView.addArrangedSubview(headerStackView)
        stackView.addArrangedSubview(addressLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalTo: labelStackView.heightAnchor, multiplier: 1.2),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        
    }

}

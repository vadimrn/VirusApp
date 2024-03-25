import UIKit

class HumanCollectionViewCell: UICollectionViewCell {
    static let identifier = "HumanCollectionViewCell"

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(imageView)
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellWith(_ item: Bool) {
        if !item {
            imageView.image = UIImage(systemName: "figure.walk.circle")
            imageView.tintColor = .systemGreen
        } else {
            imageView.image = UIImage(systemName: "figure.fall.circle")
            imageView.tintColor = .systemRed
        }
    }
}

extension HumanCollectionViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

//
//  WhatsappTextMessageCell.swift
//  ChatExample
//
//  Created by Anas J on 2/2/21.
//  Copyright © 2021 MessageKit. All rights reserved.
//

import UIKit
open class WhatsappTextMessageCell: MessageContentCell {

    // MARK: - Properties

    /// The `MessageCellDelegate` for the cell.
    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    /// The label used to display the message's text.
    open var messageLabel = MessageLabel()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = label.font.withSize(10)
        return label
    }()
    // MARK: - Methods

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.messageLabelFont = attributes.messageLabelFont
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor).isActive = true
            messageLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor).isActive = true
            messageLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: 10).isActive = true
            dateLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor).isActive = true
            messageLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor).isActive = true
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(dateLabel)
    }

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)

        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            let textMessageKind = message.kind.textMessageKind
            switch textMessageKind {
            case .text(let text), .emoji(let text):
                let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
                messageLabel.text = text
                messageLabel.textColor = textColor
                if let font = messageLabel.messageLabelFont {
                    messageLabel.font = font
                }
            case .attributedText(let text):
                messageLabel.attributedText = text
            default:
                break
            }
        }
    }
    
    /// Used to handle the cell's contentView's tap gesture.
    /// Return false when the contentView does not need to handle the gesture.
    open override func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return messageLabel.handleGesture(touchPoint)
    }

}


//
//  MovieTableViewCell.swift
//  RxDoubanMovie
//
//  Created by Mazy on 2018/9/19.
//  Copyright © 2018年 mazy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

extension UIImageView {
    
    func setImage(with url: URL?,
                  placeholder: UIImage? = nil,
                  options: KingfisherOptionsInfo = [.transition(.fade(0.2))],
                  progressBlock: DownloadProgressBlock? = nil,
                  completionHandler: CompletionHandler? = nil) {
        kf.setImage(with: url,
                    placeholder: placeholder,
                    options: options,
                    progressBlock: progressBlock,
                    completionHandler: completionHandler)
    }
}

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genresStackView: UIStackView!
    
    func configWithModel(_ model: MovieModel) {
        
        movieNameLabel.text = model.title
        directorLabel.text = model.directors.first?.name
        yearLabel.text = "\(model.year)"
        posterImageView.setImage(with: URL(string: model.image))
        
        genresStackView.arrangedSubviews.filter({ $0.tag != 888 }).forEach({ $0.removeFromSuperview() })
        for title in model.genres.reversed() {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray
            label.backgroundColor = UIColor(white: 0.9, alpha: 1)
            label.text = " \(title)  "
            label.cornerRadius = 10
            genresStackView.insertArrangedSubview(label, at: 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

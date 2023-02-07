//
//  ArticleTableViewCell.h
//  No More Paywall
//
//  Created by Matthias Vermeulen on 23/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

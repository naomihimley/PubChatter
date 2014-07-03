//
//  ChatTableViewCell.h
//  PubChatter
//
//  Created by Yeah Right on 6/28/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatLabel.h"

@interface ChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ChatLabel *rightLabel;
@property (weak, nonatomic) IBOutlet ChatLabel *leftLabel;

@end

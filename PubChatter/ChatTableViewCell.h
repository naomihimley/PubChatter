//
//  ChatTableViewCell.h
//  PubChatter
//
//  Created by Yeah Right on 6/28/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;

//The labels below are used to create some spacing between the right/left Label text and the edge of "message bubble"
@property (weak, nonatomic) IBOutlet UILabel *rightBorderEdge;
@property (weak, nonatomic) IBOutlet UILabel *leftBorderEdge;

@end

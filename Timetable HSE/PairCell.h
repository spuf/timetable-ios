//
//  PairCell.h
//  Timetable HSE
//
//  Created by Арсений Разин on 26.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PairCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

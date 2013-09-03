//
//  PairCell.m
//  Timetable HSE
//
//  Created by Арсений Разин on 26.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import "PairCell.h"

@implementation PairCell

@synthesize numberLabel = _numberLabel;
@synthesize timeLabel = _timeLabel;
@synthesize titleLabel = _titleImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

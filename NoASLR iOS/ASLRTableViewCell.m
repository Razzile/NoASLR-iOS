//
//  ASLRTableViewCell.m
//  NoASLR iOS
//
//  Created by callum taylor on 26/01/2015.
//  Copyright (c) 2015 iOSCheaters. All rights reserved.
//

#import "ASLRTableViewCell.h"

@implementation ASLRTableViewCell

- (void)awakeFromNib {
    self.maskView.backgroundColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    int width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 8 : 4;
    frame.origin.y += width;
    frame.size.height -= 2 * width;
    [super setFrame:frame];
}

@end

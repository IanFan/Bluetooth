//
//  ViewController.h
//  Bluetooth
//
//  Created by Ian Fan on 22/12/2013.
//  Copyright (c) 2013 Ian Fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueTooth.h"

@interface ViewController : UIViewController <BluetoothDelegate>
{
  UILabel *_infoLabel;
  int _messageInt;
}

@property (nonatomic,retain) Bluetooth *bluetooth;

@end

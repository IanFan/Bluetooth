//
//  ViewController.m
//  Bluetooth
//
//  Created by Ian Fan on 22/12/2013.
//  Copyright (c) 2013 Ian Fan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - BluetoothDelegate

-(void)bluetoothDelegateWithReceivedMessage:(NSString*)msgStr {
  NSLog(@"receiveStr = %@",msgStr);
  _infoLabel.text = msgStr;
}

-(void)bluetoothDelegateWithInfomationMessage:(NSString*)infoStr; {
  NSLog(@"infoStr = %@",infoStr);
  _infoLabel.text = infoStr;
}

-(void)bluetoothDelegateWithAvailableServers:(NSMutableArray*)peerIdArray {
  NSLog(@"peerIdArray = %@",peerIdArray);
  _infoLabel.text= [peerIdArray description];
}

#pragma mark - Bluetooth

-(void)setBlutoothObjects {
//  CGSize winSize = self.view.frame.size;
  
  //set BlueToothDelegate
  self.bluetooth = [Bluetooth sharedInstance];
  _bluetooth.bluetoothDelegate = self;
  [_bluetooth setDefaultWithSessionID:@"MyBluetoothSession" MaxConnections:10];
  //    [blueTooth searchServers];
  
  //ideal
  //1-1. scan possible games, show them on the screen
  //1-2. if there is no games, keep scanning
  //2. create a game
  
  //button createBtServer
  {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(20, 60, 280, 50);
  [self.view addSubview:button];
  [button addTarget:self action:@selector(bluetoothCreateNewServer) forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Create BluetoothServer" forState:UIControlStateNormal];
  }
  
  //button searchServers
  {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(20, 120, 280, 50);
  [self.view addSubview:button];
  [button addTarget:self action:@selector(bluetoothSearchServers) forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Search BluetoothServer" forState:UIControlStateNormal];
  }
  
  //button joinBtGame
  {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(20, 180, 280, 50);
  [self.view addSubview:button];
  [button addTarget:self action:@selector(bluetoothSearchServersAndJoinAutomatically) forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Join BluetoothServer" forState:UIControlStateNormal];
  }
  
  //button sendMsg
  {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(20, 240, 280, 50);
  [self.view addSubview:button];
  [button addTarget:self action:@selector(bluetoothSendMesage) forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Send Message" forState:UIControlStateNormal];
  }
  
  //button DisConnect
  {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(20, 300, 280, 50);
  [self.view addSubview:button];
  [button addTarget:self action:@selector(bluetoothDisconnect) forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Disconnect BluetoothServer" forState:UIControlStateNormal];
  }
  
  //information label
  _infoLabel = [[UILabel alloc] init];
  _infoLabel.frame = CGRectMake(20, 360, 280, 120);
  [_infoLabel setTextAlignment:NSTextAlignmentLeft];
  _infoLabel.text = @"Information: No message currently";
  _infoLabel.numberOfLines = 5;
  [self.view addSubview:_infoLabel];
}

-(void)bluetoothCreateNewServer {
  [[Bluetooth sharedInstance] createNewServer];
}

-(void)bluetoothSearchServers {
  [[Bluetooth sharedInstance] searchServers];
}

-(void)bluetoothSearchServersAndJoinAutomatically {
  [[Bluetooth sharedInstance] searchServersAndJoinAutomatically];
}

-(void)bluetoothDisconnect {
  [[Bluetooth sharedInstance] disconnect];
}

-(void)bluetoothSendMesage {
  _messageInt ++;
  [[Bluetooth sharedInstance] sendMessageWithString:[NSString stringWithFormat:@"message %d",_messageInt]];
}
  
#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  [self setBlutoothObjects];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

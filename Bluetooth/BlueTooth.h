//
//  Bluetooth.h
//  Telepathy
//
//  Created by Ian Fan on 7/01/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef enum{
  Session_Create,
  Session_Search,
  Session_Disconnect,
} SessionControl;

@protocol BluetoothDelegate;

@interface Bluetooth : NSObject <GKSessionDelegate,GKPeerPickerControllerDelegate>
{
  
  int maxConnections_;
  int connectionsCount_;
  
  BOOL isServer;
  BOOL isJoinAutomatically;
  
  NSMutableArray *unavailableServers;
}

@property (nonatomic,assign) id <BluetoothDelegate> bluetoothDelegate;

@property (nonatomic,retain) NSString *sessionID;
@property (nonatomic,retain) NSMutableArray *availableServers;
@property (nonatomic,retain) GKSession *currentSession;

+(id)sharedInstance;

-(void)setDefaultWithSessionID:(NSString*)sessionID MaxConnections:(int)maxConnections;

-(void)createNewServer;

-(void)searchServers;
-(void)searchServersAndJoinAutomatically;
-(void)joinSpecificServerWithPeerID:(NSString*)peerID;

-(void)sendMessageWithString:(NSString *)msgStr;

-(void)disconnect;

-(void)finishAndClearAll;

@end


@protocol BluetoothDelegate <NSObject>
@optional
-(void)bluetoothDelegateWithReceivedMessage:(NSString*)receiveStr;
-(void)bluetoothDelegateWithInfomationMessage:(NSString*)infoStr;
-(void)bluetoothDelegateWithAvailableServers:(NSMutableArray*)peerIdArray;
@end
//
//  bluetooth.m
//  Telepathy
//
//  Created by Ian Fan on 7/01/13.
//
//

#import "Bluetooth.h"

#define CONNECT_PEER_TIMEOUT 10.0

@implementation Bluetooth

+(id)sharedInstance {
  static id shared = nil;
  if (shared == nil) shared= [[Bluetooth alloc]init];
  
  return shared;
}

#pragma mark - Control Methods

-(void)createNewServer {
  isServer = YES;
  isJoinAutomatically = NO;
  
  [self setSessionWithControl:Session_Create];
  
  [self setInfoWithString:@"CreateTapped"];
}

-(void)searchServers {
  isServer = NO;
  isJoinAutomatically = NO;
  
  [self setSessionWithControl:Session_Search];
  
  [self setInfoWithString:@"SearchTapped"];
}

-(void)searchServersAndJoinAutomatically {
  isServer = NO;
  isJoinAutomatically = YES;
  
  [self setSessionWithControl:Session_Search];
  
  [self setInfoWithString:@"SearchAndJoinTapped"];
}

-(void)joinSpecificServerWithPeerID:(NSString*)peerID {
  isServer = NO;
  isJoinAutomatically = NO;
  
  if (_currentSession) [_currentSession connectToPeer:peerID withTimeout:CONNECT_PEER_TIMEOUT];
  
  [self setInfoWithString:[NSString stringWithFormat:@"JoinTapped: %@ ",peerID]];
}

-(void)sendMessageWithString:(NSString *)msgStr {
  if (_currentSession) [_currentSession sendDataToAllPeers:[msgStr dataUsingEncoding: NSUTF8StringEncoding] withDataMode: GKSendDataReliable error: nil];
  
  [self setInfoWithString:[NSString stringWithFormat:@"SendMsgTapped: %@",msgStr]];
}

-(void)disconnect {
  isServer = NO;
  isJoinAutomatically = NO;
  
  [self setSessionWithControl:Session_Disconnect];
  
  [self setInfoWithString:@"DisconnectTapped"];
}

-(void)finishAndClearAll {
  [self disconnect];
  [self.availableServers removeAllObjects];
  [unavailableServers removeAllObjects];
  self.bluetoothDelegate = nil;
}

-(void) setSessionWithControl:(SessionControl)sessionControl {
  NSString *sessionID = self.sessionID;
  
  switch (sessionControl) {
    case Session_Create:
      [self clearSession];
      self.currentSession = [[GKSession alloc]initWithSessionID:sessionID displayName:@"Server" sessionMode:GKSessionModeServer];
      _currentSession.delegate = self;
      _currentSession.available = YES;
      [_currentSession setDataReceiveHandler:self withContext:nil];
      [self addToUnavailableServersWithPeerID:_currentSession.peerID];
      break;
      
    case Session_Search:
      [self clearSession];
      _currentSession = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
      _currentSession.delegate = self;
      _currentSession.available = YES;
      [_currentSession setDataReceiveHandler:self withContext:nil];
      break;
      
    case Session_Disconnect:
      [self clearSession];
      break;
      
    default:
      break;
  }
  
}

-(void)clearSession {
  connectionsCount_ = 0;
  
  if (_currentSession) {
    [_currentSession disconnectFromAllPeers];
    [_currentSession setDataReceiveHandler:nil withContext:nil];
    _currentSession.available = NO;
    _currentSession.delegate = nil;
    
    self.currentSession = nil;
  }
}

#pragma mark - GKSessionDelegate

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
  switch (state) {
    case GKPeerStateAvailable:
      if ([unavailableServers containsObject:peerID] == NO) [self addToAvailableServersWithPeerID:peerID];
      
      if (isServer == YES) {
        //never happened
        NSLog(@"stateAvailable serverIsReady");
      }else {
        if (isJoinAutomatically == YES) {
          [session connectToPeer:peerID withTimeout:CONNECT_PEER_TIMEOUT];
        }
      }
      break;
      
    case GKPeerStateUnavailable:
      [self removeFromAvailableServersWithPeerID:peerID];
      [self addToUnavailableServersWithPeerID:peerID];
      break;
      
    case GKPeerStateConnected:
      connectionsCount_ ++;
      if (isServer == NO) session.available = NO;
      else {
        //disconnect the exceptions when too many connections connected in a very short time
        if (connectionsCount_ > maxConnections_) [_currentSession disconnectPeerFromAllPeers:peerID];
      }
      
      [self setInfoWithString:[NSString stringWithFormat:@"connected: %@",peerID]];
      break;
      
    case GKPeerStateDisconnected:
      connectionsCount_ --;
      if(isServer == NO) session.available = YES;
      [self setInfoWithString:[NSString stringWithFormat:@"disconnected: %@",peerID]];
      break;
      
    case GKPeerStateConnecting:
      [self setInfoWithString:[NSString stringWithFormat:@"connecting: %@",peerID]];
      break;
  }
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
  [self setInfoWithString:[NSString stringWithFormat:@"didReceiveRequest: %@",peerID]];
  
  if (session.isAvailable == NO || connectionsCount_ >= maxConnections_) [session denyConnectionFromPeer:peerID];
  else [session acceptConnectionFromPeer:peerID error:nil];

}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"MatchmakingClient: connection with peer %@ failed %@", peerID, error);
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"MatchmakingClient: session failed %@", error);
}

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
  NSString *receiveStr = [NSString stringWithFormat:@"%@> %@", [session displayNameForPeer:peer], [NSString stringWithUTF8String:[data bytes]]];
  [self setReceiveDataWithString:receiveStr];
}

//never happened
-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
  
  //picker.delegate = nil;
  //[picker dismiss];
  //picker = nil;
  NSLog(@"didConnectPeer!!!");
}

//unsed
-(void)mySendDataToPeers:(NSData *) data {
  if(_currentSession)[_currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

#pragma mark - bluetooth Protocol Methods

-(void)setReceiveDataWithString:(NSString*)receiveStr {
  if ([self.bluetoothDelegate respondsToSelector:@selector(bluetoothDelegateWithReceivedMessage:)] == YES) {
    [self.bluetoothDelegate bluetoothDelegateWithReceivedMessage:receiveStr];
  }
}

-(void)setInfoWithString:(NSString*)infoStr {
  if ([self.bluetoothDelegate respondsToSelector:@selector(bluetoothDelegateWithInfomationMessage:)] == YES) {
    [self.bluetoothDelegate bluetoothDelegateWithInfomationMessage:infoStr];
  }
}

-(void)setInfoWithAvailableServers {
  if ([self.bluetoothDelegate respondsToSelector:@selector(bluetoothDelegateWithAvailableServers:)] == YES) {
    [self.bluetoothDelegate bluetoothDelegateWithAvailableServers:self.availableServers];
  }
}

#pragma mark -
#pragma mark Tool

-(void)addToUnavailableServersWithPeerID:(NSString*)peerID {
  if ([unavailableServers containsObject:peerID] == NO) [unavailableServers addObject:peerID];
}

-(void)addToAvailableServersWithPeerID:(NSString*)peerID {
  if ([self.availableServers containsObject:peerID] == NO) [self.availableServers insertObject:peerID atIndex:0];
  [self setInfoWithAvailableServers];
}

-(void)removeFromAvailableServersWithPeerID:(NSString*)peerID {
  if ([self.availableServers containsObject:peerID] == YES) [self.availableServers removeObject:peerID];
  
  [self setInfoWithAvailableServers];
}

#pragma mark -
#pragma mark Init

-(void)setDefaultWithSessionID:(NSString*)sessionID MaxConnections:(int)maxConnections {
  self.sessionID = sessionID;
  maxConnections_ = maxConnections;
  connectionsCount_ = 0;
}

-(id)init {
  if ((self = [super init])) {
    self.availableServers = [[NSMutableArray alloc]initWithCapacity:10];
    unavailableServers = [[NSMutableArray alloc]init];
  }
  
  return self;
}

@end

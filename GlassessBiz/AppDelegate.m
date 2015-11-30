//
//  AppDelegate.m
//  GlassessBiz
//
//  Created by Guibin on 14-5-14.
//  Copyright (c) 2014年 深圳呱呱网络科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "BPush.h"

//判断是否是ios8
#define kIsISO8 [UIDevice currentDevice].systemVersion.floatValue >= 8.0f

static AppDelegate *_appDelegate;
@implementation AppDelegate
+ (AppDelegate *)getAppDelegate
{
    return _appDelegate;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _appDelegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
     NSString *userName = [SavaData getOutUserFile];
    
    LOG(@"userid = %@",USERID);
    if (USERID == nil  && userName.length == 0) {
        
        [self beginShowLoginView];
    }else{
         [[SavaData shareInstance] savadataStr:userName KeyString:USER_ID_SAVA];
        [DataStorer sharedInstance].isLogin = NO;
        HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:isPad ? @"HomeViewController-ipad":@"HomeViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
        self.window.rootViewController = nav;
    }
    
    //注册推送服务
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [BPush setupChannel:launchOptions]; // 必须
    
    [BPush setDelegate:self]; // 必须
    
    [self registerPushNotice];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)registerPushNotice{
    
    //注册推送
    if(kIsISO8) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             
                                                                             categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    
    if ([self pushNotificationOpen]) {
        NSLog(@"推送已打开");
    }else{
        NSLog(@"推送未打卡");
    }
    
}

//判断推送是否打开

- (BOOL)pushNotificationOpen
{
    if (kIsISO8)
    {
        UIUserNotificationType types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
        return (types & UIRemoteNotificationTypeAlert);
    }
    else{
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return (types & UIRemoteNotificationTypeAlert);
    }
}

- (void)showLoginVC{
    
    if (self.window.rootViewController.view != nil) {
        [self.window.rootViewController.view removeFromSuperview];
    }
    
    [self beginShowLoginView];
}
- (void)beginShowLoginView
{
    LoginViewController *loginVC = [[LoginViewController alloc]initWithNibName:isPad ? @"LoginViewController-ipad":@"LoginViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
    loginVC.navigationController.navigationBar.hidden = YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Receive Notify: %@", [userInfo JSONString]);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:alert
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    //推送消息设置
    [[SavaData shareInstance] savadataStr:@"1" KeyString:NewsImage];
    [application setApplicationIconBadgeNumber:0];
     [BPush handleNotification:userInfo];
    
    //     = [self.viewController.textView.text stringByAppendingFormat:@"Receive notification:\n%@", [userInfo JSONString]];
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [BPush registerDeviceToken:deviceToken]; // 必须
    
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    LOG(@"error = %@",error);
}
// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
//        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
//        
//        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
//        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
//        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
//        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
//        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
    }
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    //推送消息设置
    [[SavaData shareInstance] savadataStr:@"1" KeyString:NewsImage];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"标题" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     LOG(@"getUser = %@,userId = %@, channelID = %@",[BPush getAppId],[BPush getUserId],[BPush getChannelId]);
}

@end

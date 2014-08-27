//
//  AppDelegate.m
//  TagIt
//
//  Created by Steven Sickler on 8/25/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"LGoKQau3KAIoHY3aH201WncmAp4uOoNhe7nyCkqx"clientKey:@"iEJmwbIor8EqyCvZ4Jqsyu6VWv0gNpUN0t1xcODV"];
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

//    if ([PFUser currentUser]) {
//        NSLog(@"Automatically Signed User In");
//        NSLog(@"username: %@    password: %@",[PFUser currentUser].username, [PFUser currentUser].password);
//
//        //[PFUser logInWithUsernameInBackground:[PFUser currentUser].username password:[PFUser currentUser].password];
//    }else{
//
//        NSLog(@"User is not logged in");
//    }


    return YES;
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



-(void)automaticLogin{

}
@end

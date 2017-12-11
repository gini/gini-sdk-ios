//
//  ViewController.m
//  GiniSDK Example
//
//  Created by Gini on 12/10/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

#import "ViewController.h"
#import "GiniSDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Get current Gini SDK instance to upload image and process exctraction.
    GiniSDK *sdk = [GINISDKBuilder anonymousUserWithClientID:@"" clientSecret:@"" userEmailDomain:@"example" certPath:@"asd"].build;
    
    // Create a document task manager to handle document tasks on the Gini API.
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;
    
    // Create a file name for the document.
    NSString *fileName = @"your_filename";
    
    __block NSString *documentId;
    NSString* str = @"teststring";
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 1. Get session
    [[[[[sdk.sessionManager getSession] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return [sdk.sessionManager logIn];
        }
        return task.result;
        
        // 2. Create a document from the given image data
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return [manager createDocumentWithFilename:fileName fromData:data docType:@""];
        
        // 3. Get extractions from the document
    }] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *_document = (GINIDocument *)task.result;
        documentId = _document.documentId;
        NSLog(@"Created document with id: %@", documentId);
        
        return _document.extractions;
        
        // 4. Handle results
    }] continueWithBlock:^id(BFTask *task) {
        
        NSLog(@"Finished analysis process");
        
        NSDictionary *userInfo;
        NSString *notificationName;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
        });
        
        return nil;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

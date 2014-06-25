/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIDocumentTaskManager.h"
#import "GINIDocument.h"
#import <Bolts/Bolts.h>


@implementation GINIDocumentTaskManager {
    GINIAPIManager *_apiManager;
}

#pragma mark - Factory

+ (instancetype)documentTaskManagerWithAPIManager:(GINIAPIManager *)apiManager {
    NSParameterAssert([apiManager isKindOfClass:[GINIAPIManager class]]);

    return [[GINIDocumentTaskManager alloc] initWithAPIManager:apiManager];
}

#pragma mark - Initializer
- (instancetype)initWithAPIManager:(GINIAPIManager *)apiManager {
    self = [super init];
    if (self) {
        _apiManager = apiManager;

    }
    return self;
}

#pragma mark - Document methods
- (BFTask *)getDocumentWithId:(NSString *)documentId{
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    return [[_apiManager getDocument:documentId] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *document = [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
        return document;
    }];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName fromImage:(UIImage *)image {
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([UIImage isKindOfClass:[UIImage class]]);

    return [[_apiManager uploadDocumentWithData:UIImagePNGRepresentation(image) contentType:@"image/png" fileName:fileName] continueWithSuccessBlock:^id(BFTask *task) {
        return [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
    }];
}

- (BFTask *)deleteDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return [_apiManager deleteDocument:document.documentId];
}

- (BFTask *)pollDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    // Immediately return already processed documents.
    if (document.state == GiniDocumentStateComplete) {
        return [BFTask taskWithResult:document];
    }

    return [self pollDocumentWithId:document.documentId];
}

- (BFTask *)pollDocumentWithId:(NSString *)documentId{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [self pollDocumentWithId:documentId completionSource:taskCompletionSource];
    return taskCompletionSource.task;
}

- (void)pollDocumentWithId:(NSString *)documentId completionSource:(BFTaskCompletionSource *)taskCompletionSource {
    [[_apiManager getDocument:documentId] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [taskCompletionSource setError:task.error];
        } else {
            NSDictionary *polledDocument = task.result;
            if ([[polledDocument objectForKey:@"progress"] isEqualToString:@"PENDING"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.pollingInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self pollDocumentWithId:documentId completionSource:taskCompletionSource];
                });
            } else {
                GINIDocument *document = [GINIDocument documentFromAPIResponse:polledDocument withDocumentManager:self];
                [taskCompletionSource setResult:document];
            }
        }
        return nil;
    }];
}

- (BFTask *)getPreviewForPage:(NSUInteger)page ofDocument:(GINIDocument *)document withSize:(GiniApiPreviewSize)size {
    NSParameterAssert(page > 0);
    NSParameterAssert(page <= document.pageCount);

    return [_apiManager getPreviewForPage:page ofDocument:document.documentId withSize:size];
}

#pragma mark - Extraction methods
- (BFTask *)getExtractionsForDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return [_apiManager getExtractionsForDocument:document.documentId];
}

- (BFTask *)getLayoutForDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return [_apiManager getLayoutForDocument:document.documentId];
}

@end

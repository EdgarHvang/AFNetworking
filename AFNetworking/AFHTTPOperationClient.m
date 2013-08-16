//
//  AFHTTPOperationClient.m
//  
//
//  Created by Kevin Harwood on 8/16/13.
//
//

#import "AFHTTPOperationClient.h"

@implementation AFHTTPOperationClient

- (instancetype)initWithBaseURL:(NSURL *)url{
    self = [super initWithBaseURL:url];
    if(!self){
        return nil;
    }
    
    self.operationQueue = [[NSOperationQueue alloc] init];
	[self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    
    return self;
}

#pragma mark -

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                                                    failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
         if(success){
             success(op.response,responseObject);
         }
    }
     failure:^(AFHTTPRequestOperation *op, NSError *error) {
         if(failure){
             failure(error);
         }
     }];
    
    operation.allowsInvalidSSLCertificate = self.allowsInvalidSSLCertificate;
    
    return operation;
}

#pragma mark -
- (AFHTTPRequestOperation *)startRequest:(NSURLRequest *)request
                                 success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                                 failure:(void (^)(NSError *error))failure{
    AFHTTPRequestOperation *op = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                        failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super GET:URLString parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(NSHTTPURLResponse *response))success
                         failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super HEAD:URLString parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                         failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super POST:URLString parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                         failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super POST:URLString parameters:parameters constructingBodyWithBlock:block success:success failure:failure];
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                        failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super PUT:URLString parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                          success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                          failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super PATCH:URLString parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(NSDictionary *)parameters
                           success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                           failure:(void (^)(NSError *error))failure{
    return (AFHTTPRequestOperation*)[super DELETE:URLString parameters:parameters success:success failure:failure];
}

#pragma mark
- (void)cancelAllRequests{
    [self.operationQueue cancelAllOperations];
}

#pragma mark -

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation
{
    [self.operationQueue addOperation:operation];
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method
                                     path:(NSString *)path
{
    [self cancelAllHTTPOperationsWithMethod:method URLString:path];
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method
                                URLString:(NSString *)URLString
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    NSURL *URLToBeMatched = [[self requestWithMethod:(method ?: @"GET") URLString:URLString parameters:nil] URL];
#pragma clang diagnostic pop
    
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        
        BOOL hasMatchingMethod = !method || [method isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]];
        BOOL hasMatchingURL = [[[(AFHTTPRequestOperation *)operation request] URL] isEqual:URLToBeMatched];
        
        if (hasMatchingMethod && hasMatchingURL) {
            [operation cancel];
        }
    }
}

- (void)enqueueBatchOfHTTPRequestOperationsWithRequests:(NSArray *)requests
                                          progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
                                        completionBlock:(void (^)(NSArray *operations))completionBlock
{
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSURLRequest *request in requests) {
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
        [mutableOperations addObject:operation];
    }
    
    [self enqueueBatchOfHTTPRequestOperations:mutableOperations progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)enqueueBatchOfHTTPRequestOperations:(NSArray *)operations
                              progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
                            completionBlock:(void (^)(NSArray *operations))completionBlock
{
    __block dispatch_group_t group = dispatch_group_create();
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(operations);
            }
        });
    }];
    
    for (AFHTTPRequestOperation *operation in operations) {
        operation.completionGroup = group;
        void (^originalCompletionBlock)(void) = [operation.completionBlock copy];
        __weak __typeof(&*operation)weakOperation = operation;
        operation.completionBlock = ^{
            __strong __typeof(&*weakOperation)strongOperation = weakOperation;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_queue_t queue = strongOperation.completionQueue ?: dispatch_get_main_queue();
#pragma clang diagnostic pop
            dispatch_group_async(group, queue, ^{
                if (originalCompletionBlock) {
                    originalCompletionBlock();
                }
                
                NSUInteger numberOfFinishedOperations = [[operations indexesOfObjectsPassingTest:^BOOL(id op, NSUInteger __unused idx,  BOOL __unused *stop) {
                    return [op isFinished];
                }] count];
                
                if (progressBlock) {
                    progressBlock(numberOfFinishedOperations, [operations count]);
                }
                
                dispatch_group_leave(group);
            });
        };
        
        dispatch_group_enter(group);
        [batchedOperation addDependency:operation];
    }
    [self.operationQueue addOperations:operations waitUntilFinished:NO];
    [self.operationQueue addOperation:batchedOperation];
}

@end

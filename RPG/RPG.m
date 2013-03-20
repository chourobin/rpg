//
//  RPG.m
//  RPG
//
//  Created by Robin Chou on 3/19/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import "RPG.h"

@interface RPG()
-(void)handleRPGCompletionBlockResponse:(NSURLResponse *)response body:(NSData *)data error:(NSError *)error block:(RPGCompletionBlock)block;

@end

@implementation Character

- (id)initWithAttributeDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.characterID = [dictionary objectForKey:@"id"];
        self.name = [dictionary objectForKey:@"name"];
        self.characterClass = [dictionary objectForKey:@"character_type"];
    }
    return self;
}

-(NSDictionary *)requestProperties
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.name           ? self.name : [NSNull null], @"name",
            self.characterClass ? self.characterClass : [NSNull null],  @"character_type",
            nil];
}

@end

@implementation Monster
@synthesize name;
@end

@implementation RPG
// initialization

+(RPG *)sharedClient
{
    return [self sharedClientWithKey:nil managedObjectContext:nil];
}

+(RPG *)sharedClientWithKey:(NSString *)key managedObjectContext:(NSManagedObjectContext *)context
{
    static RPG *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[RPG alloc] init];
        [sharedClient setApiKey:key];
        [sharedClient setManagedObjectContext:context];
    });
    return sharedClient;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - Public Methods

// RESTful Authentication

-(void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(RPGKeyBlock)block
{
    NSURL *url = [self urlWithPath:@"/sessions"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[RPG sharedClient] encodedDataFromEmail:email password:password];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RPG sharedClient] handleRPGKeyBlockResponse:response body:data error:error block:block];
    }];
}

-(void)signUpWithEmail:(NSString *)email password:(NSString *)password completion:(RPGKeyBlock)block
{
    NSURL *url = [self urlWithPath:@"/users"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[RPG sharedClient] encodedDataFromEmail:email password:password];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RPG sharedClient] handleRPGKeyBlockResponse:response body:data error:error block:block];
    }];
}

-(void)getCharacters:(RPGCompletionBlock)block
{
    NSURL *url = [self urlWithPath:@"/characters"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:[NSString stringWithFormat:@"Token token=%@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self handleRPGCompletionBlockResponse:response body:data error:error block:block];
    }];
}

-(void)getCharacterWithID:(NSNumber *)identifier completion:(RPGCharacterBlock)block
{
    NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"/characters/%@", identifier]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:[NSString stringWithFormat:@"Token token=%@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self handleRPGCharacterBlockResponse:response body:data error:error block:block];
    }];
}

-(void)postCharacter:(Character *)character completion:(RPGCharacterBlock)block
{
    NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"/characters"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[RPG sharedClient] encodedDataFromCharacter:character];
    [request setValue:[NSString stringWithFormat:@"Token token=%@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self handleRPGCharacterBlockResponse:response body:data error:error block:block];
    }];
}

-(void)putCharacter:(Character *)character completion:(RPGCharacterBlock)block
{
    NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"/characters/%@", character.characterID]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = [[RPG sharedClient] encodedDataFromCharacter:character];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Token token=%@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self handleRPGCharacterBlockResponse:response body:data error:error block:block];
    }];
}

-(void)deleteCharacter:(Character *)character completion:(RPGCharacterBlock)block
{
    NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"/characters/%@", character.characterID]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"DELETE";
    [request setValue:[NSString stringWithFormat:@"Token token=%@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self handleRPGCharacterBlockResponse:response body:data error:error block:block];
    }];
}

-(void)createRandomMonster:(RPGMonsterBlock)block
{
    if (!self.managedObjectContext) {
        block(nil, [NSError errorWithDomain:@"RPGError" code:500 userInfo:@{NSLocalizedDescriptionKey: @"Must set managed object context"}]);
        return;
    }
    NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"/monsters"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"Token token=%@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self handleRPGMonsterBlockResponse:response body:data error:error block:block];
    }];
}

#pragma mark - Private Helpers

-(NSURL *)urlWithPath:(NSString *)path
{
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:kApiBase]];
}

-(NSData *)encodedDataFromCharacter:(Character *)character
{
    NSMutableString *body = [NSMutableString string];
    NSDictionary *attributes = [character requestProperties];
    for (NSString *key in attributes) {
        NSString *value = [attributes objectForKey:key];
        if ((id)value == [NSNull null]) continue;
        
        if (body.length != 0)
            [body appendString:@"&"];
        
        if ([value isKindOfClass:[NSString class]])
            value = [self URLEncodedString:value];
        
        [body appendFormat:@"character[%@]=%@", [self URLEncodedString:key], value];
    }
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *)encodedDataFromEmail:(NSString *)email password:(NSString *)password
{
    NSMutableString *body = [NSMutableString string];
    NSDictionary *attributes = @{@"email":email, @"password":password};
    
    for (NSString *key in attributes) {
        NSString *value = [attributes objectForKey:key];
        if ((id)value == [NSNull null]) continue;
        
        if (body.length != 0)
            [body appendString:@"&"];
        
        if ([value isKindOfClass:[NSString class]])
            value = [self URLEncodedString:value];
        
        [body appendFormat:@"user[%@]=%@", [self URLEncodedString:key], value];
    }
    
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)URLEncodedString:(NSString *)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i)
    {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ')
            [output appendString:@"+"];
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                 (thisChar >= 'a' && thisChar <= 'z') ||
                 (thisChar >= 'A' && thisChar <= 'Z') ||
                 (thisChar >= '0' && thisChar <= '9'))
            [output appendFormat:@"%c", thisChar];
        else
            [output appendFormat:@"%%%02X", thisChar];
    }
    return output;
}

-(void)handleRPGCharacterBlockResponse:(NSURLResponse *)response body:(NSData *)data error:(NSError *)error block:(RPGCharacterBlock)block
{
    if (error) {
        block(nil, error);
    } else {
        NSError *parseError;
        NSDictionary *characterData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (characterData == nil) {
            block(nil, parseError);
        } else if ([(NSHTTPURLResponse *)response statusCode] == 201 || [(NSHTTPURLResponse *)response statusCode] == 200) {
            Character *character = [[Character alloc] initWithAttributeDictionary:characterData];
            block(character, nil);
        } else {
            block(nil, [self errorFromData:characterData code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }
}

-(void)handleRPGMonsterBlockResponse:(NSURLResponse *)response body:(NSData *)data error:(NSError *)error block:(RPGMonsterBlock)block
{
    if (error) {
        block(nil, error);
    } else {
        NSError *parseError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if (jsonDictionary == nil)
            block(nil, parseError);
        else if ([(NSHTTPURLResponse *)response statusCode] == 201) {
            Monster *monster = [NSEntityDescription insertNewObjectForEntityForName:@"Monster" inManagedObjectContext:self.managedObjectContext];
            monster.name = [jsonDictionary objectForKey:@"name"];
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"%@", [error localizedDescription]);
            }
            block(monster, nil);
        } else {
            block(nil, [self errorFromData:jsonDictionary code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }
}

-(void)handleRPGCompletionBlockResponse:(NSURLResponse *)response body:(NSData *)data error:(NSError *)error block:(RPGCompletionBlock)block
{
    if (error) {
        block(nil, error);
    } else {
        NSError *parseError;
        id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (responseData == nil) {
            block(nil, parseError);
        } else if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            block([self charactersFromResponseData:responseData], nil);
        } else {
            block(nil, [self errorFromData:responseData code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }
}

-(void)handleRPGKeyBlockResponse:(NSURLResponse *)response body:(NSData *)data error:(NSError *)error block:(RPGKeyBlock)block
{
    if (error) {
        block(nil, error);
    } else {
        NSError *parseError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if (jsonDictionary == nil)
            block(nil, parseError);
        else if ([(NSHTTPURLResponse *)response statusCode] == 201) {
            self.apiKey = [jsonDictionary objectForKey:@"api_key"];
            block(self.apiKey, nil);
        } else {
            block(nil, [self errorFromData:jsonDictionary code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }
}

-(NSError *)errorFromData:(id)data code:(NSInteger)code;
{
    NSString *error;
    if ([data isKindOfClass:[NSDictionary class]]) {
        error = [data objectForKey:@"error"];
    }
    if (!error) {
        error = @"Unknown Error";
    }
    return [NSError errorWithDomain:@"RPGAPIError" code:code userInfo:@{NSLocalizedDescriptionKey:error}];
}

-(NSArray *)charactersFromResponseData:(id)response
{
    if ([response isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in response) {
            Character *ch = [[Character alloc] initWithAttributeDictionary:dict];
            [array addObject:ch];
        }
        return array;
    } else {
        return nil;
    }
}

@end

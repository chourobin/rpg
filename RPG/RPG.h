//
//  RPG.h
//  RPG
//
//  Created by Robin Chou on 3/19/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kApiBase @"http://rpgexampleapp.herokuapp.com"

@interface Character : NSObject

@property (strong, nonatomic) NSNumber *characterID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *characterClass;

@end

@interface Monster : NSManagedObject

@property (strong, nonatomic) NSString *name;

@end

typedef void (^RPGKeyBlock)(NSString *apiKey, NSError* error);
typedef void (^RPGCompletionBlock)(NSArray *characters, NSError* error);
typedef void (^RPGCharacterBlock)(Character *character, NSError* error);
typedef void (^RPGMonsterBlock)(Monster *monster, NSError *error);

@interface RPG : NSObject
 
+(RPG*)sharedClient;
+(RPG*)sharedClientWithKey:(NSString *)key managedObjectContext:(NSManagedObjectContext *)context;

// 1. Authenticate with the backend
// This method returns either an API Key to persist across reboots or an error message.

-(void)signUpWithEmail:(NSString *)email password:(NSString *)password completion:(RPGKeyBlock)block;
-(void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(RPGKeyBlock)block;

// 2. GET/POST/PUT/DELETE a Character
// After authenticating, these methods are available from the singleton class to get/post/put/delete a character

-(void)getCharacters:(RPGCompletionBlock)block;
-(void)getCharacterWithID:(NSNumber *)identifier completion:(RPGCharacterBlock)block;
-(void)postCharacter:(Character *)character completion:(RPGCharacterBlock)block;
-(void)putCharacter:(Character *)character completion:(RPGCharacterBlock)block;
-(void)deleteCharacter:(Character *)character completion:(RPGCharacterBlock)block;

// 3. Generate a random monster

-(void)createRandomMonster:(RPGMonsterBlock)block;

@property (nonatomic, copy) NSString *apiKey;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

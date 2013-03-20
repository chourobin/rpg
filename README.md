Static Library for an RPG demo
==========

# Installation

1. Drag libRPG.a and libRPG.h into your Xcode Project.
2. Create a Monster entity in your CoreData model with a string attribute called "name".

# Usage

<pre>
# Authenticate with the webservice backend residing at http://rpgexampleapp.herokuapp.com
-(void)signUpWithEmail:(NSString *)email password:(NSString *)password completion:(RPGKeyBlock)block;
-(void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(RPGKeyBlock)block;


# Create, update, and delete your characters
-(void)getCharacters:(RPGCompletionBlock)block;
-(void)getCharacterWithID:(NSNumber *)identifier completion:(RPGCharacterBlock)block;
-(void)postCharacter:(Character *)character completion:(RPGCharacterBlock)block;
-(void)putCharacter:(Character *)character completion:(RPGCharacterBlock)block;
-(void)deleteCharacter:(Character *)character completion:(RPGCharacterBlock)block;

# Generate a random monster to fight!
-(void)createRandomMonster:(RPGMonsterBlock)block;
</pre>
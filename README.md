Static Library for an RPG demo
==========

# Installation

1. Drag libRPG.a and libRPG.h into your Xcode Project.
2. Create a Monster entity in your CoreData model with a string attribute called "name".

# Usage

<pre>
# Authenticate with the webservice backend residing at http://rpgexampleapp.herokuapp.com
[[RPG sharedClient] signUpWithEmail:email password:password completion:^(NSString *apiKey, NSError *error) {
	#save api key to keychain
}];

# set key and context when rebooting app and the user is already signed in
[RPG sharedClientWithKey:key managedObjectContext:context];

# Create, update, and delete your characters
[[RPG sharedClient] getCharacters:^(NSArray *characters, NSError *error) {
}];

[[RPG sharedClient] postCharacter:nil completion:^(Character *character, NSError *error) {
}];

[[RPG sharedClient] putCharacter:nil completion:^(Character *character, NSError *error) {
}];

[[RPG sharedClient] deleteCharacter:nil completion:^(Character *character, NSError *error) {
}];

# Generate a random monster to fight!
-(void)createRandomMonster:(RPGMonsterBlock)block;
</pre>
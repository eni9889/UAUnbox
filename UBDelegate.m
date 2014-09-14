//
// UBDelegate.m
// Unbox
//
// Created by Árpád Goretity on 07/11/2011
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "UBDelegate.h"
#import "rocketbootstrap.h"

@implementation UBDelegate

- (id)init
{
	if ((self = [super init])) {
		center = [CPDistributedMessagingCenter centerNamed:@"com.unlimapps.uaunbox"];
		rocketbootstrap_distributedmessagingcenter_apply(center);
		[center runServerOnCurrentThread];

		[center registerForMessageName:@"com.unlimapps.uaunbox.move" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.copy" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.symlink" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.delete" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.attributes" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.dircontents" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.chmod" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.exists" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.isdir" target:self selector:@selector(handleMessageNamed:userInfo:)];
		[center registerForMessageName:@"com.unlimapps.uaunbox.mkdir" target:self selector:@selector(handleMessageNamed:userInfo:)];

		fileManager = [[NSFileManager alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[fileManager release];
	[super dealloc];
}

- (NSDictionary *)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)info
{
	NSString *sourceFile = [info objectForKey:@"UBSourceFile"];
	NSString *targetFile = [info objectForKey:@"UBTargetFile"];
	NSNumber *modeNumber = [info objectForKey:@"UBFileMode"];
	const char *source = [sourceFile UTF8String];
	const char *target = [targetFile UTF8String];
	mode_t mode = [modeNumber intValue];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];

	if ([name isEqualToString:@"com.unlimapps.uaunbox.move"]) {
		[fileManager moveItemAtPath:sourceFile toPath:targetFile error:NULL];
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.copy"]) {
		[fileManager copyItemAtPath:sourceFile toPath:targetFile error:NULL];
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.symlink"]) {
		symlink(source, target);
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.delete"]) {
		[fileManager removeItemAtPath:targetFile error:NULL];
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.attributes"]) {
		[result setDictionary:[fileManager attributesOfItemAtPath:targetFile error:NULL]];
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.dircontents"]) {
		NSArray *contents = [fileManager contentsOfDirectoryAtPath:targetFile error:NULL];
		if (contents) {
			[result setObject:contents forKey:@"UBDirContents"];
		}
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.chmod"]) {
		chmod(target, mode);
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.exists"]) {
		BOOL exists = access(target, F_OK);
		NSNumber *num = [[NSNumber alloc] initWithBool:exists];
		[result setObject:num forKey:@"UBFileExists"];
		[num release];
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.isdir"]) {
		struct stat buf;
		stat(target, &buf);
		BOOL isDir = S_ISDIR(buf.st_mode);
		NSNumber *num = [[NSNumber alloc] initWithBool:isDir];
		[result setObject:num forKey:@"UBIsDirectory"];
		[num release];
	} else if ([name isEqualToString:@"com.unlimapps.uaunbox.mkdir"]) {
		[fileManager createDirectoryAtPath:targetFile withIntermediateDirectories:YES attributes:nil error:NULL];
	}

	return result;
}

- (void)dummy {
	// Keep the timer alive ;)
	NSLog(@"Keeping server alive");
}

@end

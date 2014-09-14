//
// UBClient.m
// Unbox
//
// Created by Árpád Goretity on 07/11/2011
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "UBClient.h"
#import "rocketbootstrap.h"

@implementation UBClient

+ (id)sharedInstance
{
	static id shared = nil;
	if (shared == nil) {
		shared = [[self alloc] init];
	}

	return shared;
}

- (id)init
{
	if ((self = [super init])) {
		center = [CPDistributedMessagingCenter centerNamed:@"com.unlimapps.uaunbox"];
		rocketbootstrap_distributedmessagingcenter_apply(center);
	}

	return self;
}

- (NSString *)temporaryFile
{
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	NSString *path = [NSString stringWithFormat:@"/tmp/%@.tmp", uuid];
	CFRelease(uuid);
	return path;
}

- (void)moveFile:(NSString *)file1 toFile:(NSString *)file2
{
	if (file1 == nil || file2 == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file1 forKey:@"UBSourceFile"];
	[info setObject:file2 forKey:@"UBTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.move" userInfo:info];
	[info release];
}

- (void)copyFile:(NSString *)file1 toFile:(NSString *)file2
{
	if (file1 == nil || file2 == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file1 forKey:@"UBSourceFile"];
	[info setObject:file2 forKey:@"UBTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.copy" userInfo:info];
	[info release];
}

- (void)symlinkFile:(NSString *)file1 toFile:(NSString *)file2
{
	if (file1 == nil || file2 == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file1 forKey:@"UBSourceFile"];
	[info setObject:file2 forKey:@"UBTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.symlink" userInfo:info];
	[info release];
}

- (void)deleteFile:(NSString *)file
{
	if (file == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"UBTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.delete" userInfo:info];
	[info release];
}

- (NSDictionary *)attributesOfFile:(NSString *)file
{
	if (file == nil) {
		return nil;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"UBTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.attributes" userInfo:info];
	[info release];
	return reply;
}

- (NSArray *)contentsOfDirectory:(NSString *)dir
{
	if (dir == nil) {
		return nil;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:dir forKey:@"UBTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.dircontents" userInfo:info];
	[info release];
	NSArray *result = [reply objectForKey:@"UBDirContents"];
	return result;
}

- (void)chmodFile:(NSString *)file mode:(mode_t)mode
{
	if (file == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"UBTargetFile"];
	NSNumber *modeNumber = [[NSNumber alloc] initWithInt:mode];
	[info setObject:modeNumber forKey:@"UBFileMode"];
	[modeNumber release];
	[center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.chmod" userInfo:info];
	[info release];
}

- (BOOL)fileExists:(NSString *)file
{
	if (file == nil) {
		return NO;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"UBTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.exists" userInfo:info];
	[info release];
	BOOL result = [(NSNumber *)[reply objectForKey:@"UBFileExists"] boolValue];
	return result;
}

- (BOOL)fileIsDirectory:(NSString *)file
{
	if (file == nil) {
		return NO;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"UBTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.isdir" userInfo:info];
	[info release];
	BOOL result = [(NSNumber *)[reply objectForKey:@"UBIsDirectory"] boolValue];
	return result;
}

- (void)createDirectory:(NSString *)dir
{
	if (dir == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:dir forKey:@"UBTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.unlimapps.uaunbox.mkdir" userInfo:info];
	[info release];
}

@end

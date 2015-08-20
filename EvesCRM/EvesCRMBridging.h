//
//  EvesCRMBridging.h
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//



#import <DropboxSDK/DropboxSDK.h>
#import <ENSDK/ENSDK.h>


#import "ENSDK/ENNotebook.h"
#import "ENSDK/ENNoteRef.h"
#import "ENSDK/ENNoteContent.h"
#import "ENSDK/ENNote.h"
#import "ENSDK/ENNoteSearch.h"
#import "ENSDK/ENResource.h"
#import "ENSDK/ENError.h"
#import "ENSDK/ENSession.h"
#import "ENSDK/ENCommonUtils.h"
#import "ENSDK/Advanced/ENSDKAdvanced.h"
#import "ENSDK/ENSaveToEvernoteActivity.h"

#import "DropboxSDK/DBAccountInfo.h"
#import "DropboxSDK/DBSession.h"
#import "DropboxSDK/DBRestClient.h"
#import "DropboxSDK/DBRequest.h"
#import "DropboxSDK/DBMetadata.h"
#import "DropboxSDK/DBQuota.h"
#import "DropboxSDK/DBError.h"
#import "DropboxSDK/NSString+Dropbox.h"
#import "DropboxSDK/DBDeltaEntry.h"

#import "DropboxSDK/DBSession+iOS.h"

#import "LiveConnectClient.h"

// Gmail

#import "/Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/Utilities/GTLUtilities.h"
#import "/Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/Source/GTMHTTPFetcherLogging.h"
#import "/Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/gtm-oauth2-master/Source/GTMOAuth2Authentication.h"
#import "/Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/gtm-oauth2-master/Source/GTMOAuth2SignIn.h"
#import "/Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/gtm-oauth2-master/Source/Touch/GTMOAuth2ViewControllerTouch.h"

#import <Google/SignIn.h>


// Facebook
#import <FBSDKCoreKit/FBSDKCoreKit.h>

// TextExpander
#import "TextExpander/SMTEDelegateController.h"
//
//  DropboxCoreService.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 8/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyDropboxCoreDelegate
{
    func myDropboxFileDidLoad(fileName: String)
    func myDropboxFileLoadFailed(error:NSError)
    func myDropboxFileProgress(fileName: String, progress:CGFloat)
    func myDropboxMetadataLoaded(metadata:DBMetadata)
    func myDropboxMetadataFailed(error:NSError)
    func myDropboxLoadAccountInfo(info:DBAccountInfo)
    func myDropboxLoadAccountInfoFailed(error:NSError)
    func myDropboxFileDidUpload(destPath:String, srcPath:String, metadata:DBMetadata)
    func myDropboxFileUploadFailed(error:NSError)
    func myDropboxUploadProgress(progress:CGFloat, destPath:String, srcPath:String)
    func myDropboxFileLoadRevisions(revisions:NSArray, path:String)
    func myDropboxFileLoadRevisionsFailed(error:NSError)
    func myDropboxCreateFolder(folder:DBMetadata)
    func myDropboxCreateFolderFailed(error:NSError)
    func myDropboxFileDeleted(path:String)
    func myDropboxFileDeleteFailed(error:NSError)
    func myDropboxFileCopiedLoad(fromPath:String, toPath:DBMetadata)
    func myDropboxFileCopyFailed(error:NSError)
    func myDropboxFileMoved(fromPath:String, toPath:DBMetadata)
    func myDropboxFileMoveFailed(error:NSError)
    func myDropboxFileDidLoadSearch(results:NSArray, path:String, keyword:String)
    func myDropboxFileLoadSearchFailed(error:NSError)
}

class DropboxCoreService: UIViewController, DBRestClientDelegate
{
    /*  Some work to do
Note that a DBSession can be linked with more than one Dropbox, for example you could allow users to connect with both their work and personal Dropboxes. In that case, you'll want to use the -[DBRestClient initWithSession:userId:] method to specify the account. You can get an array of all connected accounts from [DBSession sharedSession].userIds.

*/
    private var dbRestClient: DBRestClient?
    var delegate: MyDropboxCoreDelegate?
    
    func setup()
    {
        let accountManager = DBSession(appKey: "1qayzo6cmw8v6nr", appSecret: "739onip24zh142y", root: kDBRootDropbox)
        DBSession.setSharedSession(accountManager)
        
        //   let accountManager = DBAccountManager(appKey: "1qayzo6cmw8v6nr", secret: "739onip24zh142y")
        //   DBAccountManager.setSharedManager(accountManager)
    }
    
    func initiateAuthentication(viewController: UIViewController)
    {
        DBSession.sharedSession().linkFromController(viewController)
    }
    
    func finalizeAuthentication(url: NSURL) -> Bool
    {
        var retVal: Bool = false
        
        _ = DBSession.sharedSession().handleOpenURL(url)
        
        if DBSession.sharedSession().isLinked()
        {
            retVal = true
        }
        
        return retVal
    }
    
    func isAlreadyInitialised() -> Bool
    {
        return DBSession.sharedSession().isLinked()
    }
    
    func listFolders(inPath: String)
    {
        
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.loadMetadata(inPath)
        
    }
    
    func loadFile(inFile: String, targetFile: String)
    {
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
    
        dbRestClient!.loadFile(inFile, intoPath: targetFile)
    }
    
    func uploadFile(inFile:String, toPath:String, fromPath:String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        _ = "\(toPath)/\(inFile)"
        
        
        // This is to insert a new file
        dbRestClient!.uploadFile(inFile, toPath: toPath, withParentRev:nil, fromPath:fromPath)
        
    }

    func loadRevisionsForFile(inFile:String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        // This is to insert a new file
        dbRestClient!.loadRevisionsForFile(inFile)
    }
    
    
      func createFolder(inPath: String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.createFolder(inPath)
        
    }
    
    func deletePath(inPath: String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.deletePath(inPath)
        
    }
    
    func copyFrom (fromPath: String, toPath:String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.copyFrom(fromPath, toPath: toPath)
        
    }
    
    func moveFrom(fromPath: String, toPath:String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.moveFrom(fromPath, toPath: toPath)
        
    }
    
    func loadAccountInfo()
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.loadAccountInfo()
        
    }
    
    func searchPath(inPath:String, forKeyword: String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.searchPath(inPath, forKeyword: forKeyword)
    }
 

    func restClient(client:DBRestClient, loadedMetadata metadata:DBMetadata)
    {
        delegate?.myDropboxMetadataLoaded(metadata)
    }
    
    func restClient(client:DBRestClient, loadMetadataFailedWithError error:NSError)
    {
        delegate?.myDropboxMetadataFailed(error)
    }
    
   // func restClient(client:DBRestClient, loadedFile destPath:String)
    func restClient(client:DBRestClient, loadedFile destPath:String, contentType:String, metadata:DBMetadata)
    {
        delegate?.myDropboxFileDidLoad(destPath)
    }
    
    func restClient(client:DBRestClient, loadFileFailedWithError error:NSError)
    {
        delegate?.myDropboxFileLoadFailed(error)
    }
    
    func restClient(client:DBRestClient, loadProgress progress:CGFloat, destPath:String)
    {
        delegate?.myDropboxFileProgress(destPath, progress: progress)
    }
    
    func restClient(client:DBRestClient, loadedAccountInfo info:DBAccountInfo)
    {
        delegate?.myDropboxLoadAccountInfo(info)
    }
    
    func restClient(client:DBRestClient, loadAccountInfoFailedWithError error:NSError)
    {
        delegate?.myDropboxLoadAccountInfoFailed(error)
    }
    
    func restClient(client:DBRestClient, uploadedFile destPath:String, srcPath:String, metadata:DBMetadata)
    {
        delegate?.myDropboxFileDidUpload(destPath, srcPath: srcPath, metadata: metadata)
    }
    
    func restClient(client:DBRestClient, uploadFileFailedWithError error:NSError)
    {
        delegate?.myDropboxFileUploadFailed(error)
    }
    
    func restClient(client:DBRestClient, uploadProgress progress:CGFloat, destPath:String, srcPath:String)
    {
        delegate?.myDropboxUploadProgress(progress, destPath: destPath, srcPath: srcPath)
    }
   
    func restClient(client:DBRestClient, loadedRevisions revisions:NSArray, path:String)
    {
        delegate?.myDropboxFileLoadRevisions(revisions, path: path)
    }
    
    func restClient(client:DBRestClient, loadRevisionsFailedWithError error:NSError)
    {
        delegate?.myDropboxFileLoadRevisionsFailed(error)
    }
    
    func restClient(client:DBRestClient, createdFolder folder:DBMetadata)
    {
        delegate?.myDropboxCreateFolder(folder)
    }
    
    func restClient(client:DBRestClient, createFolderFailedWithError error:NSError)
    {
        delegate?.myDropboxCreateFolderFailed(error)
    }
    
    func restClient(client:DBRestClient, deletedPath path:String)
    {
        delegate?.myDropboxFileDeleted(path)
    }
    
    func restClient(client:DBRestClient, deletePathFailedWithError error:NSError)
    {
        delegate?.myDropboxFileDeleteFailed(error)
    }

    func restClient(client:DBRestClient, copiedPath fromPath:String, to:DBMetadata)
    {
        delegate?.myDropboxFileCopiedLoad(fromPath, toPath: to)
    }
    
    func restClient(client:DBRestClient, copyPathFailedWithError error:NSError)
    {
        delegate?.myDropboxFileCopyFailed(error)
    }

    func restClient(client:DBRestClient, movedPath fromPath:String, to:DBMetadata)
    {
        delegate?.myDropboxFileMoved(fromPath, toPath: to)
    }
    
    func restClient(client:DBRestClient, movePathFailedWithError error:NSError)
    {
        delegate?.myDropboxFileMoveFailed(error)
    }
 
    func restClient(client:DBRestClient, loadedSearchResults results:NSArray, path:String, keyword:String)
    {
        delegate?.myDropboxFileDidLoadSearch(results, path: path, keyword: keyword)
    }
    
    func restClient(client:DBRestClient, searchFailedWithError error:NSError)
    {
        delegate?.myDropboxFileLoadSearchFailed(error)
    }
}
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
    func myDropboxFileDidLoad(_ fileName: String)
    func myDropboxFileLoadFailed(_ error:NSError)
    func myDropboxFileProgress(_ fileName: String, progress:CGFloat)
    func myDropboxMetadataLoaded(_ metadata:DBMetadata)
    func myDropboxMetadataFailed(_ error:NSError)
    func myDropboxLoadAccountInfo(_ info:DBAccountInfo)
    func myDropboxLoadAccountInfoFailed(_ error:NSError)
    func myDropboxFileDidUpload(_ destPath:String, srcPath:String, metadata:DBMetadata)
    func myDropboxFileUploadFailed(_ error:NSError)
    func myDropboxUploadProgress(_ progress:CGFloat, destPath:String, srcPath:String)
    func myDropboxFileLoadRevisions(_ revisions:NSArray, path:String)
    func myDropboxFileLoadRevisionsFailed(_ error:NSError)
    func myDropboxCreateFolder(_ folder:DBMetadata)
    func myDropboxCreateFolderFailed(_ error:NSError)
    func myDropboxFileDeleted(_ path:String)
    func myDropboxFileDeleteFailed(_ error:NSError)
    func myDropboxFileCopiedLoad(_ fromPath:String, toPath:DBMetadata)
    func myDropboxFileCopyFailed(_ error:NSError)
    func myDropboxFileMoved(_ fromPath:String, toPath:DBMetadata)
    func myDropboxFileMoveFailed(_ error:NSError)
    func myDropboxFileDidLoadSearch(_ results:NSArray, path:String, keyword:String)
    func myDropboxFileLoadSearchFailed(_ error:NSError)
}

class DropboxCoreService: UIViewController, DBRestClientDelegate
{
    /*  Some work to do
Note that a DBSession can be linked with more than one Dropbox, for example you could allow users to connect with both their work and personal Dropboxes. In that case, you'll want to use the -[DBRestClient initWithSession:userId:] method to specify the account. You can get an array of all connected accounts from [DBSession sharedSession].userIds.

*/
    fileprivate var dbRestClient: DBRestClient?
    var delegate: MyDropboxCoreDelegate?
    
    func setup()
    {
        let accountManager = DBSession(appKey: "1qayzo6cmw8v6nr", appSecret: "739onip24zh142y", root: kDBRootDropbox)
        DBSession.setSharedSession(accountManager)
        
        //   let accountManager = DBAccountManager(appKey: "1qayzo6cmw8v6nr", secret: "739onip24zh142y")
        //   DBAccountManager.setSharedManager(accountManager)
    }
    
    func initiateAuthentication(_ viewController: UIViewController)
    {
        DBSession.sharedSession().linkFromController(viewController)
    }
    
    func finalizeAuthentication(_ url: URL) -> Bool
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
    
    func listFolders(_ inPath: String)
    {
        
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.loadMetadata(inPath)
        
    }
    
    func loadFile(_ inFile: String, targetFile: String)
    {
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
    
        dbRestClient!.loadFile(inFile, intoPath: targetFile)
    }
    
    func uploadFile(_ inFile:String, toPath:String, fromPath:String)
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

    func loadRevisionsForFile(_ inFile:String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        // This is to insert a new file
        dbRestClient!.loadRevisionsForFile(inFile)
    }
    
    
      func createFolder(_ inPath: String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.createFolder(inPath)
        
    }
    
    func deletePath(_ inPath: String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.deletePath(inPath)
        
    }
    
    func copyFrom (_ fromPath: String, toPath:String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.copyFrom(fromPath, toPath: toPath)
        
    }
    
    func moveFrom(_ fromPath: String, toPath:String)
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
    
    func searchPath(_ inPath:String, forKeyword: String)
    {  // Untested
        if dbRestClient == nil
        {
            dbRestClient = DBRestClient(session: DBSession.sharedSession())
            dbRestClient!.delegate = self
        }
        
        dbRestClient!.searchPath(inPath, forKeyword: forKeyword)
    }
 

    func restClient(_ client:DBRestClient, loadedMetadata metadata:DBMetadata)
    {
        delegate?.myDropboxMetadataLoaded(metadata)
    }
    
    func restClient(_ client:DBRestClient, loadMetadataFailedWithError error:NSError)
    {
        delegate?.myDropboxMetadataFailed(error)
    }
    
   // func restClient(client:DBRestClient, loadedFile destPath:String)
    func restClient(_ client:DBRestClient, loadedFile destPath:String, contentType:String, metadata:DBMetadata)
    {
        delegate?.myDropboxFileDidLoad(destPath)
    }
    
    func restClient(_ client:DBRestClient, loadFileFailedWithError error:NSError)
    {
        delegate?.myDropboxFileLoadFailed(error)
    }
    
    func restClient(_ client:DBRestClient, loadProgress progress:CGFloat, destPath:String)
    {
        delegate?.myDropboxFileProgress(destPath, progress: progress)
    }
    
    func restClient(_ client:DBRestClient, loadedAccountInfo info:DBAccountInfo)
    {
        delegate?.myDropboxLoadAccountInfo(info)
    }
    
    func restClient(_ client:DBRestClient, loadAccountInfoFailedWithError error:NSError)
    {
        delegate?.myDropboxLoadAccountInfoFailed(error)
    }
    
    func restClient(_ client:DBRestClient, uploadedFile destPath:String, srcPath:String, metadata:DBMetadata)
    {
        delegate?.myDropboxFileDidUpload(destPath, srcPath: srcPath, metadata: metadata)
    }
    
    func restClient(_ client:DBRestClient, uploadFileFailedWithError error:NSError)
    {
        delegate?.myDropboxFileUploadFailed(error)
    }
    
    func restClient(_ client:DBRestClient, uploadProgress progress:CGFloat, destPath:String, srcPath:String)
    {
        delegate?.myDropboxUploadProgress(progress, destPath: destPath, srcPath: srcPath)
    }
   
    func restClient(_ client:DBRestClient, loadedRevisions revisions:NSArray, path:String)
    {
        delegate?.myDropboxFileLoadRevisions(revisions, path: path)
    }
    
    func restClient(_ client:DBRestClient, loadRevisionsFailedWithError error:NSError)
    {
        delegate?.myDropboxFileLoadRevisionsFailed(error)
    }
    
    func restClient(_ client:DBRestClient, createdFolder folder:DBMetadata)
    {
        delegate?.myDropboxCreateFolder(folder)
    }
    
    func restClient(_ client:DBRestClient, createFolderFailedWithError error:NSError)
    {
        delegate?.myDropboxCreateFolderFailed(error)
    }
    
    func restClient(_ client:DBRestClient, deletedPath path:String)
    {
        delegate?.myDropboxFileDeleted(path)
    }
    
    func restClient(_ client:DBRestClient, deletePathFailedWithError error:NSError)
    {
        delegate?.myDropboxFileDeleteFailed(error)
    }

    func restClient(_ client:DBRestClient, copiedPath fromPath:String, to:DBMetadata)
    {
        delegate?.myDropboxFileCopiedLoad(fromPath, toPath: to)
    }
    
    func restClient(_ client:DBRestClient, copyPathFailedWithError error:NSError)
    {
        delegate?.myDropboxFileCopyFailed(error)
    }

    func restClient(_ client:DBRestClient, movedPath fromPath:String, to:DBMetadata)
    {
        delegate?.myDropboxFileMoved(fromPath, toPath: to)
    }
    
    func restClient(_ client:DBRestClient, movePathFailedWithError error:NSError)
    {
        delegate?.myDropboxFileMoveFailed(error)
    }
 
    func restClient(_ client:DBRestClient, loadedSearchResults results:NSArray, path:String, keyword:String)
    {
        delegate?.myDropboxFileDidLoadSearch(results, path: path, keyword: keyword)
    }
    
    func restClient(_ client:DBRestClient, searchFailedWithError error:NSError)
    {
        delegate?.myDropboxFileLoadSearchFailed(error)
    }
}

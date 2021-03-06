//
//  DropboxCoreService.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 8/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import SwiftyDropbox

//protocol MyDropboxCoreDelegate
//{
//    func myDropboxFileDidLoad(_ fileName: String)
//    func myDropboxFileLoadFailed(_ error:NSError)
//    func myDropboxFileProgress(_ fileName: String, progress:CGFloat)
//    func myDropboxMetadataLoaded(_ metadata:DBMetadata)
//    func myDropboxMetadataFailed(_ error:NSError)
//    func myDropboxLoadAccountInfo(_ info:DBAccountInfo)
//    func myDropboxLoadAccountInfoFailed(_ error:NSError)
//    func myDropboxFileDidUpload(_ destPath:String, srcPath:String, metadata:DBMetadata)
//    func myDropboxFileUploadFailed(_ error:NSError)
//    func myDropboxUploadProgress(_ progress:CGFloat, destPath:String, srcPath:String)
//    func myDropboxFileLoadRevisions(_ revisions:NSArray, path:String)
//    func myDropboxFileLoadRevisionsFailed(_ error:NSError)
//    func myDropboxCreateFolder(_ folder:DBMetadata)
//    func myDropboxCreateFolderFailed(_ error:NSError)
//    func myDropboxFileDeleted(_ path:String)
//    func myDropboxFileDeleteFailed(_ error:NSError)
//    func myDropboxFileCopiedLoad(_ fromPath:String, toPath:DBMetadata)
//    func myDropboxFileCopyFailed(_ error:NSError)
//    func myDropboxFileMoved(_ fromPath:String, toPath:DBMetadata)
//    func myDropboxFileMoveFailed(_ error:NSError)
//    func myDropboxFileDidLoadSearch(_ results:NSArray, path:String, keyword:String)
//    func myDropboxFileLoadSearchFailed(_ error:NSError)
//}

struct dropBoxDisplay
{
    var displayData: TableData!
    var file: String!
}

class dropboxService: NSObject
{
    private var dBoxClient: DropboxClient!
    private var myFiles: [dropBoxDisplay] = Array()
    
    var delegate: internalCommunicationDelegate!
    
    var searchString: String = ""
    
    var files: [dropBoxDisplay]
    {
        get
        {
            return myFiles
        }
    }
    
    override init()
    {
        super.init()
        notificationCenter.addObserver(self, selector: #selector(self.assignClient), name: NotificationDropBoxConnected, object: nil)
    }
    
    func setup(targetViewController: UIViewController)
    {
        if DropboxClientsManager.authorizedClient?.auth.client.accessToken  == ""
        {
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: targetViewController,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.openURL(url)
            })
        }
        else
        {
            notificationCenter.post(name: NotificationDropBoxReady, object: nil)
        }
    }
    
    func assignClient()
    {
        dBoxClient = DropboxClientsManager.authorizedClient
        notificationCenter.post(name: NotificationDropBoxReady, object: nil)
    }
    
    func searchFiles(_ path: String)
    {
        var returnArray: [TableData] = Array()
        
        if dBoxClient == nil
        {
            dBoxClient = DropboxClientsManager.authorizedClient
        }
        
        myFiles.removeAll()
        
        let sem = DispatchSemaphore(value: 0);

        dBoxClient.files.search(path: path, query: searchString, mode: .filenameAndContent).response
            { response, error in
                if let workingResponse = response
                {
                    for myMatch in workingResponse.matches
                    {
                        let tempData = TableData(displayText: "\(myMatch.metadata.pathDisplay!)")
                        
                        returnArray.append(tempData)
                        let tempEntry = dropBoxDisplay(displayData: tempData, file: "\(myMatch.metadata.pathDisplay!)")
                        
                        self.myFiles.append(tempEntry)
                    }
                }
                else if let error = error
                {
                    print(error)
                }
                sem.signal()
            }
        
        sem.wait()
        
        if myFiles.count == 0
        {
            let tempData = TableData(displayText: "No Files Found")
            
            returnArray.append(tempData)
            let tempEntry = dropBoxDisplay(displayData: tempData, file: "")
            
            myFiles.append(tempEntry)
        }
        
        delegate.displayResults(sourceService: "DropBox", resultsArray: returnArray)
    }
    
    func openDropBox(rowID: Int)
    {
        // Dropbox does not currently support URL scheme links to files, so this just does nothing.  It is here in case Dropbo introduces support
//        if myFiles[rowID].file != ""
//        {
//            let myPath = " \(myFiles[rowID].file!)"
//            
//            let escapedString = myPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            
//            let fullPath = "dbapi-8://1/viewLink?url=\(escapedString!)"
//            let myUrl: URL = URL(string: fullPath)!
//            
//            if UIApplication.shared.canOpenURL(URL(string: "dropbox://")!)
//            {
//                UIApplication.shared.open(myUrl, options: [:],
//                                          completionHandler:
//                    {
//                        (success) in
//                        let _ = 1
//                })
//            }
//        }
    }

    
//    func initiateAuthentication(_ viewController: UIViewController)
//    {
//        DBSession.sharedSession().linkFromController(viewController)
//    }
//    
//    func finalizeAuthentication(_ url: URL) -> Bool
//    {
//        var retVal: Bool = false
//        
//        _ = DBSession.sharedSession().handleOpenURL(url)
//        
//        if DBSession.sharedSession().isLinked()
//        {
//            retVal = true
//        }
//        
//        return retVal
//    }
//    
//    func isAlreadyInitialised() -> Bool
//    {
//        return DBSession.sharedSession().isLinked()
//    }
    
//    func listFolders(_ path: String)
//    {
//        
//        if dBoxClient == nil
//        {
//            dBoxClient = DropboxClientsManager.authorizedClient
//        }
//        
//     //   dBoxClient.files.listFolder(path: path)
//        
//        let result = dBoxClient.files.listFolder(path: path)
//        
//print("listFolders - Result = \(result)")
//        
//        // Build the return string
//        
//        var returnString = "No return value"
//        
//        delegate.displayResults(sourceService: "DropBox", resultsString: returnString)
//        
////        dBoxClient.files.listFolder(path: path)
////            .response { response, error in
////                if let response = response {
////                    let responseMetadata = response.0
////print("listFolders = responseMetadata = \(responseMetadata)")
////                    let fileContents = response.1
////print("listFolders = fileContents = \(fileContents)")
////                } else if let error = error {
////                    print(error)
////                }
////            }
////            .progress { progressData in
////                print(progressData)
////        }
//    }
    
//    func loadFile(_ sourceFile: String, targetFile: String)
//    {
//        if dBoxClient == nil
//        {
//            dBoxClient = DropboxClientsManager.authorizedClient
//        }
//    
//        let result = dBoxClient.files.download(path: sourceFile)
//        
//print("loadFile - Result = \(result)")
//        
//        // Build the return string
//        
//        var returnString = "No return value"
//        
//        delegate.displayResults(sourceService: "DropBox", resultsString: returnString)
//        
////        dBoxClient.files.download(path: sourceFile)
////            .response { response, error in
////                if let response = response {
////                    let responseMetadata = response.0
////print("loadFile = responseMetadata = \(responseMetadata)")
////                    let fileContents = response.1
////print("loadFile = fileContents = \(fileContents)")
////                } else if let error = error {
////                    print(error)
////                }
////            }
////            .progress { progressData in
////                print(progressData)
////        }
//    }
    
//    func uploadFile(_ inFile:String, toPath:String, fromPath:String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        _ = "\(toPath)/\(inFile)"
//        
//        
//        // This is to insert a new file
//        dBoxClient!.uploadFile(inFile, toPath: toPath, withParentRev:nil, fromPath:fromPath)
//        
//    }
//
//    func loadRevisionsForFile(_ inFile:String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        // This is to insert a new file
//        dBoxClient!.loadRevisionsForFile(inFile)
//    }
//    
//    
//      func createFolder(_ inPath: String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        dBoxClient!.createFolder(inPath)
//        
//    }
//    
//    func deletePath(_ inPath: String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        dBoxClient!.deletePath(inPath)
//        
//    }
//    
//    func copyFrom (_ fromPath: String, toPath:String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        dBoxClient!.copyFrom(fromPath, toPath: toPath)
//        
//    }
//    
//    func moveFrom(_ fromPath: String, toPath:String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        dBoxClient!.moveFrom(fromPath, toPath: toPath)
//        
//    }
    
//    func loadAccountInfo()
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        dbRestClient!.loadAccountInfo()
//        
//    }
//    
//    func searchPath(_ inPath:String, forKeyword: String)
//    {  // Untested
//        if dBoxClient == nil
//        {
//            dBoxClient = DBRestClient(session: DBSession.sharedSession())
//            dBoxClient!.delegate = self
//        }
//        
//        dBoxClient!.searchPath(inPath, forKeyword: forKeyword)
//    }
 

//    func restClient(_ client:DBRestClient, loadedMetadata metadata:DBMetadata)
//    {
//        delegate?.myDropboxMetadataLoaded(metadata)
//    }
//    
//    func restClient(_ client:DBRestClient, loadMetadataFailedWithError error:NSError)
//    {
//        delegate?.myDropboxMetadataFailed(error)
//    }
//    
//   // func restClient(client:DBRestClient, loadedFile destPath:String)
//    func restClient(_ client:DBRestClient, loadedFile destPath:String, contentType:String, metadata:DBMetadata)
//    {
//        delegate?.myDropboxFileDidLoad(destPath)
//    }
//    
//    func restClient(_ client:DBRestClient, loadFileFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileLoadFailed(error)
//    }
//    
//    func restClient(_ client:DBRestClient, loadProgress progress:CGFloat, destPath:String)
//    {
//        delegate?.myDropboxFileProgress(destPath, progress: progress)
//    }
//    
//    func restClient(_ client:DBRestClient, loadedAccountInfo info:DBAccountInfo)
//    {
//        delegate?.myDropboxLoadAccountInfo(info)
//    }
//    
//    func restClient(_ client:DBRestClient, loadAccountInfoFailedWithError error:NSError)
//    {
//        delegate?.myDropboxLoadAccountInfoFailed(error)
//    }
//    
//    func restClient(_ client:DBRestClient, uploadedFile destPath:String, srcPath:String, metadata:DBMetadata)
//    {
//        delegate?.myDropboxFileDidUpload(destPath, srcPath: srcPath, metadata: metadata)
//    }
//    
//    func restClient(_ client:DBRestClient, uploadFileFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileUploadFailed(error)
//    }
//    
//    func restClient(_ client:DBRestClient, uploadProgress progress:CGFloat, destPath:String, srcPath:String)
//    {
//        delegate?.myDropboxUploadProgress(progress, destPath: destPath, srcPath: srcPath)
//    }
//   
//    func restClient(_ client:DBRestClient, loadedRevisions revisions:NSArray, path:String)
//    {
//        delegate?.myDropboxFileLoadRevisions(revisions, path: path)
//    }
//    
//    func restClient(_ client:DBRestClient, loadRevisionsFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileLoadRevisionsFailed(error)
//    }
//    
//    func restClient(_ client:DBRestClient, createdFolder folder:DBMetadata)
//    {
//        delegate?.myDropboxCreateFolder(folder)
//    }
//    
//    func restClient(_ client:DBRestClient, createFolderFailedWithError error:NSError)
//    {
//        delegate?.myDropboxCreateFolderFailed(error)
//    }
//    
//    func restClient(_ client:DBRestClient, deletedPath path:String)
//    {
//        delegate?.myDropboxFileDeleted(path)
//    }
//    
//    func restClient(_ client:DBRestClient, deletePathFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileDeleteFailed(error)
//    }
//
//    func restClient(_ client:DBRestClient, copiedPath fromPath:String, to:DBMetadata)
//    {
//        delegate?.myDropboxFileCopiedLoad(fromPath, toPath: to)
//    }
//    
//    func restClient(_ client:DBRestClient, copyPathFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileCopyFailed(error)
//    }
//
//    func restClient(_ client:DBRestClient, movedPath fromPath:String, to:DBMetadata)
//    {
//        delegate?.myDropboxFileMoved(fromPath, toPath: to)
//    }
//    
//    func restClient(_ client:DBRestClient, movePathFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileMoveFailed(error)
//    }
// 
//    func restClient(_ client:DBRestClient, loadedSearchResults results:NSArray, path:String, keyword:String)
//    {
//        delegate?.myDropboxFileDidLoadSearch(results, path: path, keyword: keyword)
//    }
//    
//    func restClient(_ client:DBRestClient, searchFailedWithError error:NSError)
//    {
//        delegate?.myDropboxFileLoadSearchFailed(error)
//    }
}

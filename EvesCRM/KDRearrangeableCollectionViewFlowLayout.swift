//
//  KDRearrangeableCollectionViewFlowLayout.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

class KDRearrangeableCollectionViewFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    var animating : Bool = false
    
    var collectionViewFrameInCanvas : CGRect = CGRect.zero
    
    var hitTestRectagles = [String:CGRect]()
  
    var canvas : UIView? {
        didSet {
            if canvas != nil {
                self.calculateBorders()
            }
        }
    }
    
    struct Bundle {
        var offset : CGPoint = CGPoint.zero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : IndexPath
    }
    var bundle : Bundle?
    
    
    override init() {
        super.init()
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        
        if let collectionView = self.collectionView {
/*
            let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        
            longPressGestureRecogniser.minimumPressDuration = 0.2
            longPressGestureRecogniser.delegate = self

            collectionView.addGestureRecognizer(longPressGestureRecogniser)
*/
            let longPressGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
            
            longPressGestureRecogniser.minimumNumberOfTouches = 1
            longPressGestureRecogniser.delegate = self
            
            collectionView.addGestureRecognizer(longPressGestureRecogniser)
            
            if self.canvas == nil {
                
                self.canvas = self.collectionView!.superview
                
            }
            
            
        }
    }
    
    override func prepare() {
        super.prepare()
        self.calculateBorders()
    }
    
    fileprivate func calculateBorders() {
        
        if let collectionView = self.collectionView {
            
            collectionViewFrameInCanvas = collectionView.frame
 //Insert by GRE
            if self.canvas == nil {
                
                self.canvas = self.collectionView!.superview
                
            }
 // End insert
            if self.canvas != collectionView.superview {
                collectionViewFrameInCanvas = self.canvas!.convert(collectionViewFrameInCanvas, from: collectionView)
            }
            
            
            var leftRect : CGRect = collectionViewFrameInCanvas
            leftRect.size.width = 20.0
            hitTestRectagles["left"] = leftRect
            
            var topRect : CGRect = collectionViewFrameInCanvas
            topRect.size.height = 20.0
            hitTestRectagles["top"] = topRect
            
            var rightRect : CGRect = collectionViewFrameInCanvas
            rightRect.origin.x = rightRect.size.width - 20.0
            rightRect.size.width = 20.0
            hitTestRectagles["right"] = rightRect
            
            var bottomRect : CGRect = collectionViewFrameInCanvas
            bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height - 20.0
            bottomRect.size.height = 20.0
            hitTestRectagles["bottom"] = bottomRect
            
           
            
            
        }
        
        
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
   
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let ca = self.canvas {
            
            if let cv = self.collectionView {
                
                let pointPressedInCanvas = gestureRecognizer.location(in: ca)
                
                for cell in cv.visibleCells {
                    
                    let cellInCanvasFrame = ca.convert(cell.frame, from: cv)
                    
                    if cellInCanvasFrame.contains(pointPressedInCanvas ) {
                        
                        let representationImage = cell.snapshotView(afterScreenUpdates: true)
                        representationImage?.frame = cellInCanvasFrame
                        
                        let offset = CGPoint(x: pointPressedInCanvas.x - cellInCanvasFrame.origin.x, y: pointPressedInCanvas.y - cellInCanvasFrame.origin.y)
                        
                        let indexPath : IndexPath = cv.indexPath(for: cell as UICollectionViewCell)!
                        
                        self.bundle = Bundle(offset: offset, sourceCell: cell, representationImageView:representationImage!, currentIndexPath: indexPath)
                        
                        
                        break
                    }
                    
                }
                
            }
            
        }
        return (self.bundle != nil)
    }
    
    
    
//    func checkForDraggingAtTheEdgeAndAnimatePaging(gestureRecognizer: UILongPressGestureRecognizer) {
        func checkForDraggingAtTheEdgeAndAnimatePaging(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if self.animating == true {
            return
        }
        
        if let bundle = self.bundle {
            
            
            _ = gestureRecognizer.location(in: self.canvas)
            
           
            var nextPageRect : CGRect = self.collectionView!.bounds
            
            if self.scrollDirection == UICollectionViewScrollDirection.horizontal {
                
                if bundle.representationImageView.frame.intersects(hitTestRectagles["left"]!) {
                   
                    nextPageRect.origin.x -= nextPageRect.size.width
                    
                    if nextPageRect.origin.x < 0.0 {
                        
                        nextPageRect.origin.x = 0.0
                        
                    }
                    
                }
                else if bundle.representationImageView.frame.intersects(hitTestRectagles["right"]!) {
                  
                    nextPageRect.origin.x += nextPageRect.size.width
                    
                    if nextPageRect.origin.x + nextPageRect.size.width > self.collectionView!.contentSize.width {
                        
                        nextPageRect.origin.x = self.collectionView!.contentSize.width - nextPageRect.size.width
                        
                    }
                }
                
                
            }
            else if self.scrollDirection == UICollectionViewScrollDirection.vertical {
                
                _ = hitTestRectagles["top"]
                
                
                if bundle.representationImageView.frame.intersects(hitTestRectagles["top"]!) {
                    
                    
                    nextPageRect.origin.y -= nextPageRect.size.height
                    
                    if nextPageRect.origin.y < 0.0 {
                        
                        nextPageRect.origin.y = 0.0
                        
                    }
                    
                }
                else if bundle.representationImageView.frame.intersects(hitTestRectagles["bottom"]!) {
                   
                    nextPageRect.origin.y += nextPageRect.size.height
                    
                    
                    if nextPageRect.origin.y + nextPageRect.size.height > self.collectionView!.contentSize.height {
                        
                        nextPageRect.origin.y = self.collectionView!.contentSize.height - nextPageRect.size.height
                        
                    }
                }
                
                
            }
            
            if !nextPageRect.equalTo(self.collectionView!.bounds){
                
                
                let delayTime = DispatchTime.now() + Double(Int64(0.8 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    
                    self.animating = false
                    
                    self.handleGesture(gestureRecognizer)
                    
                    
                });
                
                self.animating = true
                
                
                self.collectionView!.scrollRectToVisible(nextPageRect, animated: true)
                
            }
            
        }
        
      
    }
    
//    func handleGesture(gesture: UILongPressGestureRecognizer) -> Void
    func handleGesture(_ gesture: UIPanGestureRecognizer) -> Void
    {
        if let bundle = self.bundle
        {
            let dragPointOnCanvas = gesture.location(in: self.canvas)
            
            if gesture.state == UIGestureRecognizerState.began
            {
                bundle.sourceCell.isHidden = true
                self.canvas?.addSubview(bundle.representationImageView)
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                });
            }
            
            if gesture.state == UIGestureRecognizerState.changed
            {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPoint.zero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                
                let dragPointOnCollectionView = gesture.location(in: self.collectionView)
                
                if let _ : IndexPath = self.collectionView?.indexPathForItem(at: dragPointOnCollectionView)
                {
                    self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                    
                    
         /*           if indexPath.isEqual(bundle.currentIndexPath) == false
                    {
                        // If we have a collection view controller that implements the delegate we call the method first
                        if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate
                        {
                            delegate.moveDataItem(bundle.currentIndexPath, toIndexPath: indexPath)
                        }
                        
                        self.collectionView!.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: indexPath)
                        
                        self.bundle!.currentIndexPath = indexPath
                    } */
                }
            }
                
            if gesture.state == UIGestureRecognizerState.ended
            {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPoint.zero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                    
                let dragPointOnCollectionView = gesture.location(in: self.collectionView)
                
                if let indexPath : IndexPath = self.collectionView?.indexPathForItem(at: dragPointOnCollectionView)
                {
                    self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                        
                    if (indexPath == bundle.currentIndexPath) == false
                    {
                        // If we have a collection view controller that implements the delegate we call the method first
                        if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate
                        {
                            delegate.moveDataItem(bundle.currentIndexPath, fromIndexPath: indexPath)
                        }
                            
                        self.collectionView!.moveItem(at: bundle.currentIndexPath, to: indexPath)
                            
                        self.bundle!.currentIndexPath = indexPath
                    }
                }
            }
            
            if gesture.state == UIGestureRecognizerState.ended {
                
               
                bundle.sourceCell.isHidden = false
                bundle.representationImageView.removeFromSuperview()
                
                if let _ = self.collectionView?.delegate as? KDRearrangeableCollectionViewDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
                    self.collectionView!.reloadData()
                }
                
                self.bundle = nil
                
                
            }
            
            
        }
        
    }
    
}

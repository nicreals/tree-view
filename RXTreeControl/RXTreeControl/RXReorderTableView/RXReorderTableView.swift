//
//  FoldingCell.swift
//
// Copyright (c) 22.01.16. Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit
@objc
public protocol RXReorderTableViewCellDelegate: NSObjectProtocol {
  optional func changeOpenStateByCell(cell: UITableViewCell)
}

@objc
public protocol RXReorderTableViewDelegate: NSObjectProtocol,RXReorderTableViewCellDelegate {
  
  
  optional func tableView(tableView: UITableView, movedCell cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) -> UITableViewCell
  
  
  optional func tableView(tableView: UITableView, showMovedView view: UIView, atIndexPath indexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, hideMovedView view: UIView, toIndexPath indexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, movingSubRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexSubRowPath destinationSubRowIndexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, movingRowAtIndexPath sourceIndexPath: NSIndexPath, toRootRowPath destinationSubRowIndexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, movedSubRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexSubRowPath destinationSubRowIndexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, movedRowAtIndexPath sourceIndexPath: NSIndexPath, toRootRowPath destinationSubRowIndexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, movedRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexRowPath destinationRowIndexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, openSubAssetAtIndexPath sourceIndexPath: NSIndexPath)
  
  optional func tableView(tableView: UITableView, closeSubAssetAtIndexPath sourceIndexPath: NSIndexPath)
  
}




@objc
public protocol RXReorderTableViewDatasource: NSObjectProtocol {
  
  
  optional func selectionViewForTableView(tableView: UITableView, destinitionCell cell: UITableViewCell, toIndexRowPath destinationRowIndexPath: NSIndexPath) -> UIView
  
  
}

extension UIView {
  
  func viewImage() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
    self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let cellImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return cellImage
  }
}

enum ReorderingState {
  case Flat
  case Submenu
  case Root
}

public class RXReorderTableView: UITableView {
  
  
  public var longPressReorderDelegate: RXReorderTableViewDelegate!
  
  public var longPressReorderDatasource: RXReorderTableViewDatasource!
  
  internal var longPressGestureRecognizer: UILongPressGestureRecognizer!
  
  internal var fromIndexPath: NSIndexPath?
  
  internal var currentLocationIndexPath: NSIndexPath?
  
  internal var movedView: UIView?
  
  internal var selectionView: UIView?
  
  internal var scrollRate = 0.0
  
  internal var scrollDisplayLink: CADisplayLink?
  
  internal var reorderingState: ReorderingState = .Flat
  
  /** A Bool property that indicates whether long press to reorder is enabled. */
  public var longPressReorderEnabled: Bool {
    get {
      return longPressGestureRecognizer.enabled
    }
    set {
      longPressGestureRecognizer.enabled = newValue
    }
  }
  
  public convenience init() {
    self.init(frame: CGRect.zero)
  }
  
  public override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    initialize()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
  private func canMoveRowAt(indexPath indexPath: NSIndexPath) -> Bool {
    return (dataSource?.respondsToSelector("tableView:canMoveRowAtIndexPath:") == false) || (dataSource?.tableView?(self, canMoveRowAtIndexPath: indexPath) == true)
  }
  
  private func cancelGesture() {
    longPressGestureRecognizer.enabled = false
    longPressGestureRecognizer.enabled = true
  }
  
  internal func longPress(gesture: UILongPressGestureRecognizer) {
    
    let location = gesture.locationInView(self)
    let indexPath = indexPathForRowAtPoint(location)
    
    let rows = countRows()
    
    
    if (rows == 0) ||
      ((gesture.state == UIGestureRecognizerState.Began) && (indexPath == nil)) ||
      ((gesture.state == UIGestureRecognizerState.Ended) && (currentLocationIndexPath == nil)) ||
      ((gesture.state == UIGestureRecognizerState.Began) && !canMoveRowAt(indexPath: indexPath!)) {
        cancelGesture()
        return
    }
    
    // Started.
    if gesture.state == .Began {
      if let indexPath = indexPath, var cell = cellForRowAtIndexPath (indexPath) {
        
        cell.setSelected(false, animated: false)
        cell.setHighlighted(false, animated: false)
        
        // Create the view that will be dragged around the screen.
        if movedView == nil {
          
          if let draggingCell = longPressReorderDelegate?.tableView?(self, movedCell: cell, atIndexPath: indexPath) {
            cell = draggingCell
          }
          
          beginAnimationCellImage(cell.viewImage(), indexPath:indexPath, location: location, view: {[unowned self] (view) -> Void in
            self.longPressReorderDelegate?.tableView?(self, showMovedView: view, atIndexPath: indexPath)
            self.movedView = view
            
            })
          
        }
        
        currentLocationIndexPath = indexPath
        fromIndexPath = indexPath
        
        // Enable scrolling for cell.
        scrollDisplayLink = CADisplayLink(target: self, selector: "scrollTableWithCell:")
        scrollDisplayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
      }
    } else if gesture.state == .Changed {
       // Dragging.
      scrollRate = self.directionRate(location)
      updateCurrentLocation(gesture)
      
    } else if gesture.state == .Ended {
      // Dropped.
      self.finishScrolingOperation()
      
      if let draggingView = self.movedView, currentLocationIndexPath = self.currentLocationIndexPath {
        self.endMoveAnimationMovedView(draggingView, currentLocationIndexPath: currentLocationIndexPath, animation: { [unowned self] () in
          
          self.longPressReorderDelegate?.tableView?(self, hideMovedView: draggingView, toIndexPath: currentLocationIndexPath)
          }, complete: {[unowned self]() in
            self.movedView?.removeFromSuperview()
            self.currentLocationIndexPath = nil
            self.movedView = nil
            
            if self.fromIndexPath != currentLocationIndexPath {
              switch(self.reorderingState) {
              case .Flat:
                self.longPressReorderDelegate?.tableView!(self, movedRowAtIndexPath: self.fromIndexPath!, toIndexRowPath: currentLocationIndexPath)
                break
                
              case .Submenu:
                self.longPressReorderDelegate?.tableView?(self, movingSubRowAtIndexPath: self.fromIndexPath!, toIndexSubRowPath: currentLocationIndexPath)
              case .Root:
                self.longPressReorderDelegate?.tableView!(self, movedRowAtIndexPath: self.fromIndexPath!, toRootRowPath: currentLocationIndexPath)
                break
              }
            }
            
            
          })
      }
      
    }
    
  }
  
  

  
   func updateCurrentLocation(gesture: UILongPressGestureRecognizer) {
    let location = gesture.locationInView(self)
    if var indexPath = indexPathForRowAtPoint(location) {
      
      if let iIndexPath = fromIndexPath {
        if let ip = delegate?
          .tableView?(self, targetIndexPathForMoveFromRowAtIndexPath: iIndexPath, toProposedIndexPath: indexPath) {
          indexPath = ip
        }
      }
      
      
      if let clIndexPath = currentLocationIndexPath {
        let oldHeight = rectForRowAtIndexPath(clIndexPath).size.height
        let newHeight = rectForRowAtIndexPath(indexPath).size.height
        
        if ((indexPath != clIndexPath) &&
          (gesture.locationInView(cellForRowAtIndexPath(indexPath)).y > (newHeight - oldHeight))) &&
          canMoveRowAt(indexPath: indexPath) {
            beginUpdates()
            selectionView?.removeFromSuperview()
            selectionView = nil
            if let cell =
              cellForRowAtIndexPath(indexPath),
              selectionView =  self.longPressReorderDatasource?
                .selectionViewForTableView?(self, destinitionCell: cell, toIndexRowPath: indexPath),
              movedView = self.movedView {
              self.selectionView = selectionView
              
              if movedView.frame.origin.y <= 0 {
                self.movedView?.removeFromSuperview()
                self.movedView = nil
              }else if  movedView.frame.origin.y  < 30 {
                self.selectionView?.frame.origin.y = 0
                cell.addSubview(selectionView)
                
                self.longPressReorderDelegate?.tableView?(self, movingRowAtIndexPath: clIndexPath, toRootRowPath: indexPath)
              }else {
                
                if movedView.frame.origin.x > 20 {
                  
                  selectionView.frame.origin.x = 30
                  UIView.beginAnimations("Scale", context: nil)
                  movedView.transform = CGAffineTransformMakeScale(0.6, 0.6)
                  reorderingState = .Submenu
                  UIView.commitAnimations()
                  
                  CATransaction.begin()
                  
                  movedView.addPulseAnimationDuration(key:"animateOpacity")
                  cell.addPulseAnimationDuration()
                  

                  CATransaction.setCompletionBlock({ () -> Void in
                    self.longPressReorderDelegate.tableView?(self, openSubAssetAtIndexPath: indexPath)
                  })
                  
                  CATransaction.flush()
                }else {
                  selectionView.frame.origin.x = 0
                  UIView.beginAnimations("Scale", context: nil)
                  movedView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                  reorderingState = .Flat
                  longPressReorderDelegate.tableView?(self, closeSubAssetAtIndexPath: indexPath)
                  UIView.commitAnimations()
                  
                }
                cell.addSubview(selectionView)
              }
            }
            
            if self.reorderingState == .Flat {
              dataSource?.tableView?(self, moveRowAtIndexPath: clIndexPath, toIndexPath: indexPath)
            }else if (self.reorderingState == .Submenu) {
              longPressReorderDelegate.tableView?(self, movingSubRowAtIndexPath: clIndexPath, toIndexSubRowPath: indexPath)
            }
            currentLocationIndexPath = indexPath
            endUpdates()
        }
      }
    }
  }
  
  

  

}


  



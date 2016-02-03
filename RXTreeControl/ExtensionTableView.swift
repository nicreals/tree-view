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


import Foundation
import UIKit
import RxSwift
import RxCocoa
public typealias ItemSelectedViewEventBlock = ( cell:UITableViewCell, destinationIndex: NSIndexPath) ->Void
public typealias ItemSelectedViewEvent = ( cell:UITableViewCell, destinationIndex: NSIndexPath,viewBlock:(cell:UITableViewCell, destinationIndex: NSIndexPath)->UIView)
public typealias ItemSelectedViewBlock = (cell:UITableViewCell, destinationIndex: NSIndexPath)->UIView
public typealias ItemSubRowEvent = (NSIndexPath)



public class  RxReorderTableViewDataSourceProxy:RxTableViewDataSourceProxy,RXReorderTableViewDatasource{
    
    var selectionViewBlock :ItemSelectedViewEventBlock!
    var viewBlock : ((cell: UITableViewCell, destinationIndex: NSIndexPath)->UIView)!
    //let dataSourceObject :RXReorderDataSource =  RXReorderDataSource()
    
    
    public required init(parentObject: AnyObject) {
       
        super.init(parentObject: parentObject)
        (self.tableView as! RXReorderTableView).longPressReorderDatasource = self
       
    }

    public func selectionViewForTableView(tableView: UITableView,destinitionCell cell:UITableViewCell,toIndexRowPath destinationRowIndexPath: NSIndexPath) -> UIView{
       
        return self.viewBlock(cell: cell,destinationIndex: destinationRowIndexPath)
    }
    
    /**
     Typed parent object.
     */
   // public weak private(set) var tableView: UITableView?
    
   // private weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet
    
    /**
     Initializes `RxTableViewDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
//    public required init(parentObject: AnyObject) {
//        self.tableView = (parentObject as! UITableView)
//        super.init(parentObject: parentObject)
//    }
//    
    // MARK: delegate
    

  
    //We need a way to set the current delegate
    override public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        //let tableView: RXReorderTableView = object as! RXReorderTableView
      //  let dataSourceObject :RXReorderDataSource =  RXReorderDataSource()
        //tableView.longPressReorderDatasource =  (self.dataSourceObject as RXReorderTableViewDatasource)
        super.setCurrentDelegate(delegate, toObject: object)
        
    }
    
    
//    public func selectionViewForTableView(tableView: UITableView,destinitionCell cell:UITableViewCell,toIndexRowPath destinationRowIndexPath: NSIndexPath) -> UIView{
//        let viewBlock :(view:UIView)->Void = { view in
//            return view
//        }
//        self.selectionView = (cell,destinationRowIndexPath,viewBlock)
////        self.selectionView!(cell:cell,destinationIndex:destinationRowIndexPath,viewBlock:{ view in
////            return view
////        })
//        return UIView()
//    }
//  
    
    //func selectionViewForTableView(tableView: RXReorderTableView,destinitionCell cell:UITableViewCell,toIndexRowPath destinationRowIndexPath: NSIndexPath) -> UIView{
      

}

//public class RXReorderDataSource:NSObject,RXReorderTableViewDatasource{
//    
//    var selectionView :ItemSelectedViewEvent!
//    
//    public func selectionViewForTableView(tableView: UITableView,destinitionCell cell:UITableViewCell,toIndexRowPath destinationRowIndexPath: NSIndexPath) -> UIView{
//        let viewBlock :(view:UIView)->Void = { view in
//            return view
//        }
//     //   self.selectionView = (cell,destinationRowIndexPath,viewBlock)
//       
//        return UIView()
//    }
//
//}


public class RxReorderTableViewDelegateProxy: RxTableViewDelegateProxy,RXReorderTableViewDelegate {
    
       //We need a way to read the current delegate
    override public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let tableView: RXReorderTableView = object as! RXReorderTableView
        return tableView.longPressReorderDelegate
    }
    
    //We need a way to set the current delegate
    override public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: RXReorderTableView = object as! RXReorderTableView
        tableView.delegate = (delegate as! UITableViewDelegate)
        tableView.longPressReorderDelegate = delegate as! RXReorderTableViewDelegate
        
      
    }
    
  
    
    /**
     Typed parent object.
     */
}
    
extension RXReorderTableView{
  
//    public override  var  rx_delegate: DelegateProxy {
//        return RxReorderTableViewDelegateProxy(parentObject: self) //proxyForObject(RxReorderTableViewDelegateProxy.self,self as! RXReorderTableView  )
//    }
//    
    public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxReorderTableViewDelegateProxy(parentObject: self)
    }

    
//    /**
//     Factory method that enables subclasses to implement their own `rx_delegate`.
//     
//     - returns: Instance of delegate proxy that wraps `delegate`.
//     */
//    public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
//        return RxTableViewDelegateProxy(parentObject: self)
//    }
//    
//    /**
//     Factory method that enables subclasses to implement their own `rx_dataSource`.
//     
//     - returns: Instance of delegate proxy that wraps `dataSource`.
//     */
//    public func rx_createDataSourceProxy() -> RxTableViewDataSourceProxy {
//        return RxTableViewDataSourceProxy(parentObject: self)
//    }
//    
//    /**
//     Reactive wrapper for `dataSource`.
//     
//     For more information take a look at `DelegateProxyType` protocol documentation.
//     */
     public override  var rx_dataSource: RxReorderTableViewDataSourceProxy {
         return RxReorderTableViewDataSourceProxy(parentObject: self)
     }
//
//    /**
//     Installs data source as forwarding delegate on `rx_dataSource`.
//     
//     It enables using normal delegate mechanism with reactive delegate mechanism.
//     
//     - parameter dataSource: Data source object.
//     - returns: Disposable object that can be used to unbind the data source.
//     */
//    public func rxrsetDataSource(d: UITableViewDataSource)
//        -> Disposable {
//            let proxy = proxyForObject(RxTableViewDataSourceProxy.self, self)
//            
//            return installDelegate(proxy, delegate: d, retainDelegate: false, onProxyForObject: self)
//    }
//    
//    
    
//    public func selectionViewForTableView(tableView: UITableView,destinitionCell cell:UITableViewCell,toIndexRowPath destinationRowIndexPath: NSIndexPath) -> UIView{
//        let view = UIView()
//        view.backgroundColor = UIColor.blueColor()
//        
//    
//        return view
//    }
//    
   
//    public override func rx_createDelegateProxy() -> RxTableViewDelegateProxy {
//        return RxTableViewDelegateProxy(parentObject: self)
//    }
//
    public override var rx_delegate: DelegateProxy {
        return proxyForObject(RxReorderTableViewDelegateProxy.self, self)//RxReorderTableViewDelegateProxy(parentObject: self)//
    }
//
//    public  func rx_setDataSource(dataSource: UITableViewDataSource)
//        -> Disposable {
//            let proxy = proxyForObject(RxReorderTableViewDelegateProxy.self, self)
//            
//            return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
//    }
//    
//   
    
  
    
    
    public var rx_itemSubRowOpen: ControlEvent<ItemSubRowEvent> {
        let source: Observable<ItemSubRowEvent> = rx_delegate.observe("tableView:openSubAssetAtIndexPath:")
            .map { a in
                return ((a[1] as! NSIndexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    
    public var rx_itemSubRowClosed: ControlEvent<ItemSubRowEvent> {
        let source: Observable<ItemSubRowEvent> = rx_delegate.observe("tableView:closeSubAssetAtIndexPath:")
            .map { a in
                return ((a[1] as! NSIndexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    
    
    /*
    Reactive wrapper for `delegate` message `tableView:moveRowAtIndexPath:toIndexPath:`.
    func tableView(tableView: UITableView,movedRowAtIndexPath sourceIndexPath: NSIndexPath,toIndexRowPath destinationRowIndexPath: NSIndexPath)     */
    
    public var rx_itemRowMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_delegate.observe("tableView:movedRowAtIndexPath:toIndexRowPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /*
    Reactive wrapper for `delegate` message `tableView:movedRowAtIndexPath:toIndexPath:`.
    */
    
    public var rx_itemSubRowMovedToRoot: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_delegate.observe("tableView:movedRowAtIndexPath:toRootRowPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
        }
        
        return ControlEvent(events: source)
    }

    
    
    /*
    func tableView(tableView: UITableView, movedSubRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexSubRowPath destinationSubRowIndexPath: NSIndexPath)
    */
    
    
    public var rx_itemSubRowMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_delegate.observe("tableView:movedSubRowAtIndexPath:toIndexSubRowPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    
    /*
    Reactive wrapper for `delegate` message  func tableView(tableView: UITableView, moveSubRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexSubRowPath destinationSubRowIndexPath: NSIndexPath).
    */
    
    public var rx_itemSubRowMove: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_delegate.observe("tableView:movingSubRowAtIndexPath:toIndexSubRowPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
        }
        
        return ControlEvent(events: source)
    }
    // func tableView(tableView: UITableView, moveSubRowAtIndexPath sourceIndexPath: NSIndexPath, toRootRowPath destinationSubRowIndexPath: NSIndexPath)
    public var rx_itemMoveToRoot: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_delegate.observe("tableView:movingRowAtIndexPath:toRootRowPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath) ) //; (a[3] as! UIView)
        }
        
        return ControlEvent(events: source)
    }
    
    
    public func rx_itemSelectedView() -> ControlEvent<ItemSelectedViewBlock> {

        let source: Observable<ItemSelectedViewBlock> = create { (observer) in
            
//            let selectViewBlock = { (cell:UITableViewCell, destinationIndex: NSIndexPath) in
//            
//             
//            }
             observer.onNext(self.rx_dataSource.viewBlock)
            //self.rx_dataSource.selectionViewBlock = selectViewBlock
         
            //      Some other condition
            observer.onCompleted()
            
            return AnonymousDisposable {
                //         Dispose resources here
            }
        }
   

       // let source: Observable<ItemSelectedViewEvent> = selectedObserver()
        return ControlEvent(events: source)
   }
//    
    
      
}
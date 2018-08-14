//
//  Transation.swift
//  HomePower
//
//  Created by triumph_sha on 2018/8/2.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//


import Foundation

/// Command class for transaction
///
class CCommand : NSObject {
    //var trans = <#value#>
    
    func excute() -> Bool
    {
        return false
    }
    func undo() -> Bool {
        return false
    }
}


/// Transaction
protocol ITransaction {
    var id:Int {get}
    //var command:ICommand{get set}
    var command_stack:Set<CCommand>{get set}
    
    func set_command(cmd:CCommand) -> Void
    
    func process() -> Void
    
    func rollback() -> Void
    
}

/// Communication protocol
protocol ICommProtocol {
    func makeframe() -> Int
    func parseframe() -> Int
}

/// Command for protocol make frame
class CPrtlMakeFrameCmd:CCommand {
    var comm_protocol:ICommProtocol
    
    init(prtl:ICommProtocol) {
        comm_protocol = prtl
    }
    
    override func excute() -> Bool
    {
        let result = comm_protocol.makeframe()
        
        if result == 0{
            return true
        }
        return false
    }
}

/// Command for protocol parse frame
class CPrtlParseFrameCmd:CCommand {
    var comm_protocol:ICommProtocol
    
    init(prtl:ICommProtocol) {
        comm_protocol = prtl
    }
    
    override func excute() -> Bool
    {
        let result = comm_protocol.parseframe()
        
        if result == 0{
            return true
        }
        return false
    }
}

/// Command that communication add task to send queue
class CAddCommunicationTaskCmd:CCommand {
    var trans_added:CCommTransaction
    var comm_channel:ICommChannel
    
    init(channel:ICommChannel,trans:CCommTransaction) {
        comm_channel = channel
        trans_added = trans
    }
    
    override func excute() -> Bool
    {
        let result = comm_channel.attach_task(trans: trans_added)
        
        return result
    }
}
/// Response command
class CPersistenceCmd:CCommand {
    //var trans_added:CCommTransaction
    //var comm_channel:ICommChannel
    var request_handle:INotify
    
    init(handle:INotify) {
        request_handle = handle
    }
    
    override func excute() -> Bool
    {
        request_handle.notify(msg: Data(bytes: []))
        
        return true
    }
}
/// communication factory
class CCommCommandFactory: NSObject {
    //
    func CreatePrtlMakeFrameCmd() -> CPrtlMakeFrameCmd? {
        
        return nil
    }
    //
    func CreateSendFrameCmd() -> CAddCommunicationTaskCmd? {
        
        return nil
    }
    //
    func CreatePrtlParseFrameCmd() -> CPrtlParseFrameCmd? {
        
        return nil
    }
    //
    func CreateNotifyCmd() -> CPersistenceCmd? {
        
        return nil
    }
}

/// command invoker
/// first step: make frame by protocol,reciever is protocol
///
class CCommTransaction: ITransaction,INotify {
    // transaction id
    var id: Int
    //var command: ICommand
    var command_stack: Set<CCommand>
    // request object
    var request_object:INotify?
    // response object id
    var response_id:Int
    // request context
    var request_context:[UInt8]?
    // response cache
    var response_cache:[UInt8]?
    
    // construct func
    init(id:Int,dev_id:Int) {
        self.id = id
        response_id = dev_id
        command_stack = Set<CCommand>()
    }
    // set command for invoker
    func set_command(cmd:CCommand) -> Void{
        command_stack.insert(cmd)
    }
    
    // 1、make frame
    // 2、attach task to communication channel
    // 3、wait response and parse response
    // 4、return result
    // 5、over transaction
    func process() {
        // first make frame
        var cmd = command_stack.popFirst()
        while cmd != nil {
            if(cmd?.excute())!
            {
                
            }
        }
    }
    
    func rollback() {
        
    }
    
    func notify(msg: Data) {
        response_cache?.append(contentsOf: [UInt8](msg))
    }
}

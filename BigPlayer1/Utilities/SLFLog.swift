//
//  SLFLog.swift
//  Music_Test_1
//
//  Created by Stewart French on 11/6/20.
//

import Foundation

//---------------------------------------------------------
// This debug func will print the date/time along with the string
// passed in.  Use it this way -
//
//    SLFLog( "\(#file):\(#line), \(#function)" )
// or
//    SLFLog( "\(#function)" )
//

func SLFLog( _ s : String )
{
    let df = DateFormatter()
//    df.dateFormat = "y-MM-dd H:m:ss.SSSS"
    df.dateFormat = "H:m:ss.SSSS"
    let d = Date()
    print( df.string(from: d) + " -- " + s )

}

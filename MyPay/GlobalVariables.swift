//
//  GlobalVariables.swift
//  MyPay
//
//  Created by Konrad Rybicki on 07/09/2021.
//

/// Contains global variables, declared as static fields (ex. - currently logged user's id)

struct GlobalVariables {
    
    // logged user's data
    public static var loggedUsersId: Int16? = nil
    public static var loggedUsersAccountBalance: String? = nil
    
    // initialized database listeners
    public static var initializedListeners: [DatabaseListener] = []
}

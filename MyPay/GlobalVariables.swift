//
//  GlobalVariables.swift
//  MyPay
//
//  Created by Konrad Rybicki on 07/09/2021.
//

/// Contains global variables, declared as static fields (ex. - currently logged user's id)
    
struct GlobalVariables {
    public static var loggedUsersId: Int16? = nil
    public static var loggedUsersSCHash: String? = nil
    public static var loggedUsersSCSalt: String? = nil
    public static var loggedUsersAccountNumber: String? = nil
    public static var loggedUsersAccountBalance: String? = nil
}

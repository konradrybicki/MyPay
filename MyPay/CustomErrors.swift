//
//  CustomErrors.swift
//  MyPay
//
//  Created by Konrad Rybicki on 15/08/2021.
//

/// User-defined error type
public enum DatabaseError: Error {
    case connectionFailure
    case dataSavingFailure
    case dataLoadingFailure
    case dataUpdateFailure
    case interactionError
}

/// User-defined error type
public enum DataGenerationError: Error {
    case def
}

/// User-defined error type
public enum DataValidationError: Error {
    case def
}

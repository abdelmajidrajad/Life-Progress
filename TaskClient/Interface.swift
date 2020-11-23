import Combine
import Foundation
import CoreData

public enum TaskFailure: LocalizedError, Equatable {
    case custom(String)
    public var errorDescription: String {
        switch self {
        case let .custom(customError):
            return customError
        }
    }
}


import SwiftUI

public struct TaskRequest {
    public var viewContext: NSManagedObjectContext
    public var task: ProgressTask
    public init(
        viewContext: NSManagedObjectContext,
        task: ProgressTask
    ) {
        self.viewContext = viewContext
        self.task = task        
    }
}

public enum TaskResponse: Equatable {
    case tasks([ProgressTask])
    case created(ProgressTask)
    case updated(ProgressTask)
    case deleted(id: UUID)
}

public struct TaskClient {
    public let create: (TaskRequest) -> AnyPublisher<TaskResponse, TaskFailure>
    public let update: (TaskRequest) -> AnyPublisher<TaskResponse, TaskFailure>
    public let delete: (TaskRequest) -> AnyPublisher<TaskResponse, TaskFailure>
    public let tasks:  (NSManagedObjectContext) -> AnyPublisher<TaskResponse, TaskFailure>
    public init(
        create: @escaping
        (TaskRequest) -> AnyPublisher<TaskResponse, TaskFailure> = { _ in .none },
        update: @escaping
        (TaskRequest) -> AnyPublisher<TaskResponse, TaskFailure> = { _ in .none },
        delete: @escaping
        (TaskRequest) -> AnyPublisher<TaskResponse, TaskFailure> = { _ in .none },
        tasks:
        @escaping (NSManagedObjectContext) -> AnyPublisher<TaskResponse, TaskFailure> = { _ in .none }
    ) {
        self.create = create
        self.update = update
        self.delete = delete
        self.tasks = tasks
    }
}





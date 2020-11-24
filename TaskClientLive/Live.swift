import TaskClient
import CoreData
import Combine
import SwiftUI

extension TaskClient {
    public static var live: TaskClient {
        Self(
            create: { request in
                                
                .future { promise in
                                                           
                    let entity = NSEntityDescription.entity(
                        forEntityName: "Task",
                        in: request.viewContext
                    )!
                    
                    let taskObject = NSManagedObject(
                        entity: entity,
                        insertInto: request.viewContext
                    )
                    
                    taskObject.setProgressTask(request.task)
                                                            
                    do {
                        try request.viewContext.save()
                        currentObjects[request.task.id] = taskObject
                        promise(.success(.created(request.task)))
                    } catch {
                        promise(.failure(.custom(error.localizedDescription)))
                    }
                }
            },
            update: { request in
                .future { promise in
                                                           
                    let updatedObject = currentObjects[request.task.id]
                    updatedObject?.setProgressTask(request.task)
                    do {
                        try request.viewContext.save()
                        promise(.success(.updated(request.task)))
                    } catch {
                        promise(.failure(
                            .custom(error.localizedDescription))
                        )
                    }
                }                
            },
            delete: { request in
                .future { promise in
                                                            
                    guard let deletedObject = currentObjects[request.task.id] else {
                        promise(.failure(.custom("task not exist")))
                        return
                    }
                    do {
                        request.viewContext.delete(deletedObject)
                        try request.viewContext.save()
                        promise(.success(.deleted(id: request.task.id)))
                    } catch {
                        promise(.failure(
                            .custom(error.localizedDescription))
                        )
                    }
                    
                    
                }
            },
            tasks: { context in
                .future { promise in
                                                            
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
                    do {
                        let objects = try context.fetch(fetchRequest)
                        
                        objects.forEach {
                            currentObjects[$0.value(forKey: "id") as! UUID] = $0
                        }
                        promise(.success(
                            .tasks(objects.map(progressTask)))
                        )
                    } catch {
                        promise(.failure(.custom(error.localizedDescription)))
                    }
                }
            }
        )
    }
}

var currentObjects: [UUID: NSManagedObject] = [:]

let progressTask: (NSManagedObject) -> ProgressTask = { object in
    ProgressTask(
        id: object.value(forKey: "id") as! UUID,
        title: object.value(forKey: "title") as! String,
        startDate: object.value(forKey: "startDate") as! Date,
        endDate: object.value(forKey: "endDate") as! Date,
        creationDate: object.value(forKey: "creationDate") as! Date,
        color: object.value(forKey: "color") as! UIColor,
        style: ProgressTask.Style(rawValue: object.value(forKey: "style") as! String) ?? .bar
    )
}

extension NSManagedObject {
    var setProgressTask: (ProgressTask) -> Void {
        return { task in
            self.setValue(task.id, forKey: "id")
            self.setValue(task.title, forKey: "title")
            self.setValue(task.color, forKey: "color")
            self.setValue(task.startDate, forKey: "startDate")
            self.setValue(task.endDate, forKey: "endDate")
            self.setValue(task.creationDate, forKey: "creationDate")
            self.setValue(task.style.rawValue, forKey: "style")
        }
    }
}

extension AnyPublisher {
    public static func future(
        _ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void
    ) -> AnyPublisher {
        Deferred {
            Future { callback in
                attemptToFulfill { result in callback(result) }
            }
        }.eraseToAnyPublisher()
    }
}



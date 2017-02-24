//
//  DelegateChangeSets.swift
//  CollectionView
//
//  Created by Wesley Byrne on 1/31/17.
//  Copyright © 2017 Noun Project. All rights reserved.
//

import Foundation



public struct ResultsChangeSet {
    
    var items = ItemChangeSet()
    var sections = SectionChangeSet()
    
    public init() { }
    
    public mutating func addChange(forItemAt source: IndexPath?, with changeType: ResultsControllerChangeType) {
        items.addChange(forItemAt: source, with: changeType)
    }
    
    public mutating func addChange(forSectionAt source: IndexPath?, with changeType: ResultsControllerChangeType) {
        sections.addChange(forSectionAt: source, with: changeType)
    }
    
    public var count : Int {
        return items.count + sections.count
    }
    
    public mutating func removeAll() {
        items.reset()
        sections.reset()
    }
    
    public mutating func union(with other: ResultsChangeSet) {
        self.items.inserted.formUnion(other.items.inserted)
        self.items.deleted.formUnion(other.items.deleted)
        self.items.updated.formUnion(other.items.updated)

        self.sections.inserted.formUnion(other.sections.inserted)
        self.sections.deleted.formUnion(other.sections.deleted)
        self.sections.updated.formUnion(other.sections.updated)
    }
}


struct ItemChangeSet {
    typealias Move = (source: IndexPath, destination: IndexPath)
    
    var inserted = Set<IndexPath>()
    var deleted = Set<IndexPath>()
    var updated = Set<IndexPath>()
    var moved = [Move]()
    
    init() { }
    
    var count : Int {
        return inserted.count + deleted.count + updated.count + moved.count
    }
    
    mutating func addChange(forItemAt source: IndexPath?, with changeType: ResultsControllerChangeType) {
        switch changeType {
        case .delete:
            print("Delete item at \(source!)")
            deleted.insert(source!)
        case .update(_):
            print("Update item at \(source!)")
            updated.insert(source!)
        case let .move(newIndexPath):
            print("Move item at \(source!) to \(newIndexPath)")
            moved.append((source!, newIndexPath))
        case let .insert(newIndexPath):
            print("Insert item at \(newIndexPath)")
            inserted.insert(newIndexPath)
        }
    }
    
    mutating func reset() {
        inserted.removeAll()
        deleted.removeAll()
        updated.removeAll()
        moved.removeAll()
    }
}

struct SectionChangeSet {
     typealias Move = (source: Int, destination: Int)
    
     var inserted = IndexSet()
     var deleted = IndexSet()
     var updated = IndexSet()
     var moved = [Move]()
    
     init() { }
    
    var count : Int {
        return inserted.count + deleted.count + updated.count + moved.count
    }
    
     mutating func addChange(forSectionAt source: IndexPath?, with changeType: ResultsControllerChangeType) {
        switch changeType {
        case .delete:
            print("Delete section at \(source!)")
            deleted.insert(source!._section)
        case .update:
            print("Update section at \(source!)")
            updated.insert(source!._section)
            break;
        case let .move(newIndexPath):
            print("Move section \(source!) to \(newIndexPath)")
            moved.append((source!._section, newIndexPath._section))
        case let .insert(newIndexPath):
            print("Insert section at \(newIndexPath)")
            inserted.insert(newIndexPath._section)
        }
    }
    
     mutating func reset() {
        inserted.removeAll()
        deleted.removeAll()
        updated.removeAll()
        moved.removeAll()
    }
}


// Extension to make easy use of the ItemChangeSet and SectionChangeSet
public extension CollectionView {
    
    
    public func applyChanges(from changeSet: ResultsChangeSet, completion: AnimationCompletion? = nil) {
        guard changeSet.count > 0 else {
            completion?(true)
            return
        }
        self.performBatchUpdates({
            _applyChanges(changeSet.items)
            _applyChanges(changeSet.sections)
        }, completion: completion)
    }
    
    private func _applyChanges(_ changes: SectionChangeSet) {
        self.deleteSections(changes.deleted, animated: true)
        self.insertSections(changes.inserted, animated: true)
        self.reloadSupplementaryViews(in: changes.updated, animated: true)
    }
    
    private func _applyChanges(_ changes: ItemChangeSet) {
        self.deleteItems(at: Array(changes.deleted), animated: true)
        self.insertItems(at: Array(changes.inserted), animated: true)
        
        for move in changes.moved {
            self.moveItem(at: move.source, to: move.destination, animated: true)
        }
        self.reloadItems(at: Array(changes.updated), animated: true)
    }
    
    
}



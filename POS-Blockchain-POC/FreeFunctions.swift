//
//  FreeFunctions.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 24/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
	return { $0.map(f) }
}

public func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
	return { $0.filter(p) }
}

public func forEach<A>(_ f: @escaping (A) -> Void) -> ([A]) -> Void {
	return { arr in arr.forEach(f) }
}

public func flatMap<A, B>(_ f: @escaping (A) -> [B]) -> ([A]) -> [B] {
	return { $0.flatMap(f) }
}

public func compactMap<A, B>(_ f: @escaping (A?) -> B?) -> ([A?]) -> [B] {
    return { $0.compactMap(f) }
}

public func reduce<A, R>(_ accumulator: @escaping (R, A) -> R) -> (R) -> ([A]) -> R {
    return { initialValue in
        return { collection in
            return collection.reduce(initialValue, accumulator)
        }
    }
}

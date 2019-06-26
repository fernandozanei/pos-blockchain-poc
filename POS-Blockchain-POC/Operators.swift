//
//  Operators.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 24/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

precedencegroup FunctionApplication {
	associativity: left
}
precedencegroup FunctionComposition {
	associativity: left
	higherThan: FunctionApplication
}
infix operator >>>: FunctionComposition
infix operator |>: FunctionApplication

func >>><A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
	return { a in g(f(a)) }
}

func |><A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
	return f(a)
}

//
//  XMLParserExamples.swift
//  SwiftyCharms
//
//  Created by Kyle Fang on 2/18/16.
//  Copyright © 2016 Ruoyu Fu. All rights reserved.
//

struct XML {
    enum Content {
        case Text(String)
        case Nodes([XML])
    }
    let name:String
    let attributes:[String:String]
    let childern:Content
}

extension XML {
    static func from(head:String)(_ attributes:[String:String])(_ childern:Content)(_ foot:String) throws -> XML {
        guard head == foot else {
            throw ParserError.NotMatch
        }
        return XML(name: head, attributes: attributes, childern: childern)
    }
}

func join(array:[String]) -> String {
    return array.reduce("", combine: +)
}

func tuple<U, V>(x:U)(_ y:V) -> (U, V) {
    return (x, y)
}

func assemble<T>(keyValuePair:[(String,T)]) -> [String:T] {
    var result:[String:T] = [:]
    keyValuePair.forEach({
        result[$0.0] = $0.1
    })
    return result
}

let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".characters
    .map({one(String($0))})

let keyparser = join <^> many(oneOf(letters))

let attribute = one(" ") *> keyparser <* one("=")
let attributeValue = tuple <^> attribute <*> string
let attributes = assemble <^> many(attributeValue)

let header = one("<") *> keyparser
let attri = attributes <* whitespace <* one(">")
let textContent = XML.Content.Text <^> (join <^> many(not(one("<"))))
let nodeContent = XML.Content.Nodes <^> some(nodeParser())
let content = nodeContent <|> textContent
let footer = one("</") *> keyparser <* one(">")

let selfClosingFooter = whitespace *> one("/>")

let standardNodeParser = XML.from <^> header <*> attri <*> content <*> footer
func fromSelfClosing(header:String)(_ attributes:[String:String]) throws -> XML {
    return try XML.from(header)(attributes)(XML.Content.Text(""))(header)
}
let selfClosingNodeParser = fromSelfClosing <^> header <*> attributes <* selfClosingFooter

func nodeParser() -> Parser<XML> {
    return Parser {
        return try (standardNodeParser <|> selfClosingNodeParser).trunk($0)
    }
}


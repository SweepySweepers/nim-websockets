import tables, parseutils, macros
import annotate

#TODO - Remove me
import os, json, marshal, strutils


# Fields
const validChars = {'a'..'z', 'A'..'Z', '0'..'9'}


# Procedures
proc transform(info_string: string, result: PNimrodNode) {.compileTime.}

proc check_section(value: string, node: PNimrodNode, index, read: var int): bool {.compileTime.} =
    ## Check for opening of a statement section %{{  }}
    if value.skipWhile({'{'}, index) == 2:
        # Parse value until colon
        var sub: string
        var sub_read = value.parseUntil(sub, ':', start=index)

        # TODO - Replace statement list with parsed remainder

        var expression = parseExpr(sub.substr(2) & ": nil")
        node.add expression

        inc(index, 2)
        return true
    else:
        inc(read)


proc check_expression(value: string, node: PNimrodNode, index, read: var int) {.compileTime.} =
    ## Check for the opening of an expression, %(), otherwise
    ## if @ident parse as individual identifier

    # TODO - Check for expr

    # Process as individual variable
    var sub: string
    read += value.parseWhile(sub, validChars, start=read)

    if sub != "":
        node.add newCall("add", ident("result"), newCall("$", ident(sub)))


proc transform(info_string: string, result: PNimrodNode) =
    var transform_string = ""

    # Transform info and add to result statement list
    var index = 0
    while index < info_string.len:
        var sub: string
        var read = index + info_string.parseUntil(sub, '$', start=index)

        # Add literal string information up-to the `$` symbol
        result.add newCall("add", ident("result"), newStrLitNode(sub))

        # Check if we have reached the end of the string
        if info_string.len == read:
            break

        # Check sections, recursively calls
        # transform as needed; dropping cursor
        # back here with updated index & read
        if not info_string.check_section(result, index, read):

            # Process as individual expression
            info_string.check_expression(result, index, read)

        # Increment to next point
        index = read


macro tmpl*(body: expr): stmt =
    ## Transform `tmpl` body into nimrod code
    ## Put body into procedure named `name`
    ## which returns type `string`
    result = newStmtList()

    result.add parseExpr("if result == nil: result = \"\"")

    var value = if body.kind in nnkStrLit..nnkTripleStrLit: body
                else: body[1]

    transform(
        reindent($toStrLit(value)),
        result
    )


# Tests
when isMainModule:

    # No substitution
    proc no_substitution: string = tmpl html"""
        <div>Test!</div>
    """

    # Single variable substitution
    proc substitution(who = "nobody"): string = tmpl html"""
        <div id="greeting">hello $who!</div>
    """

    # Expression template
    proc test_expression(nums: openarray[int] = []): string =
        var i = 2
        tmpl html"""
            <div id="greeting">hello $(nums[i])</div>
        """

    # Statement template
    proc test_statements(nums: openarray[int] = []): string = ""
    # tmpl html"""
    #     <ul id="list">
    #     </ul>
    # """

    #     ${{for i in nums:
    #         <li>$i</li>
    #         <div>execute!</div>
    #     }}


    # Run template procedures
    echo no_substitution()

    echo substitution("world")

    echo test_expression([0, 2, 4, 6])

    echo test_statements([0, 2, 4, 6])
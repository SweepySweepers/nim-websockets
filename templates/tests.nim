# Fields
const x = 5


# Test substring
static:
    assert "test".substring(3)   == "t"
    assert "test".substring(3,2) == "t"
    assert "test".substring(1,2) == "es"


# Various parsing tests
when true:

    block: #no_substitution
        proc actual: string = tmpl html"""
            <p>Test!</p>
        """
        const expected = html"""
            <p>Test!</p>
        """
        echo actual()
        assert actual() == expected

    block: #basic
        proc actual: string = tmpl html"""
            <p>Test $$x</p>
            $x
        """
        const expected = html"""
            <p>Test $x</p>
            5
        """
        echo actual()
        assert actual() == expected

    block: #expression
        proc actual: string = tmpl html"""
            <p>Test $$(x * 5)</p>
            $(x * 5)
        """
        const expected = html"""
            <p>Test $(x * 5)</p>
            25
        """
        echo actual()
        assert actual() == expected

    block: #forIn
        proc actual: string = tmpl html"""
            <p>Test for</p>
            <ul>
            $for y in 0..2 {
                <li>$y</li>
            }
            </ul>
        """
        const expected = html"""
            <p>Test for</p>
            <ul>
                <li>0</li>
                <li>1</li>
                <li>2</li>
            </ul>
        """
        echo actual()
        assert actual() == expected

    block: #while
        proc actual: string = tmpl html"""
            <p>Test while/stmt</p>
            <ul>
            ${ var y = 0 }
            $while y < 4 {
                <li>$y</li>
                ${ inc(y) }
            }
            </ul>
        """
        const expected = html"""
            <p>Test while/stmt</p>
            <ul>
                <li>0</li>
                <li>1</li>
                <li>2</li>
                <li>3</li>
            </ul>
        """
        echo actual()
        assert actual() == expected

    block: #ifElifElse
        proc actual: string = tmpl html"""
            <p>Test if/elif/else</p>
            $if x == 8 {
                <div>x is 8!</div>
            }
            $elif x == 7 {
                <div>x is 7!</div>
            }
            $else {
                <div>x is neither!</div>
            }
        """
        const expected = html"""
            <p>Test if/elif/else</p>
                <div>x is neither!</div>
        """
        echo actual()
        assert actual() == expected

    block: #caseOfElse
        proc actual: string = tmpl html"""
            <p>Test case</p>
            $case x
            $of 5 {
                <div>x == 5</div>
            }
            $of 6 {
                <div>x == 6</div>
            }
            $else {
                <div>x == ?</div>
            }
        """
        const expected = html"""
            <p>Test case</p>
                <div>x == 5</div>
        """
        echo actual()
        assert actual() == expected

block: #embeddingTest
    proc no_substitution: string = tmpl html"""
        <h1>Template test!</h1>
    """

    # # Single variable substitution
    proc substitution(who = "nobody"): string = tmpl html"""
        <div id="greeting">hello $who!</div>
    """

    # Expression template
    proc test_expression(nums: openarray[int] = []): string =
        var i = 2
        tmpl html"""
            $(no_substitution())
            $(substitution("Billy"))
            <div id="age">Age: $($nums[i] & "!!")</div>
        """

    proc test_statements(nums: openarray[int] = []): string =
        tmpl html"""
            $(test_expression(nums))
            $if true {
                <ul>
                $for i in nums {
                    <li>$(i * 2)</li>
                }
                </ul>
            }
        """

    var actual = test_statements([0,1,2])
    const expected = html"""
        <h1>Template test!</h1>
        <div id="greeting">hello Billy!</div>
        <div id="age">Age: 2!!</div>
            <ul>
                <li>0</li>
                <li>2</li>
                <li>4</li>
            </ul>
    """
    echo actual
    assert actual == expected


when defined(future):
    block: #tryCatch
        proc actual: string = tmpl html"""
            <p>Test try/catch</p>
            <div>
                $try {
                    <div>Lets try this!</div>
                }
                $except {
                    <div>Uh oh!</div>
                }
            </div>
        """
        const expected = html"""
            <p>Test try/catch</p>
            <div>
                    <div>Lets try this!</div>
            </div>
        """
        echo actual()
        assert actual() == expected
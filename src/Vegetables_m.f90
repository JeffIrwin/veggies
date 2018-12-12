module Vegetables_m
    implicit none
    private

    type, public :: VegetableString_t
        private
        character(len=:), allocatable :: string
    contains
        private
        generic, public :: operator(//) => &
                concatCharsAndString, concatStringAndChars, concatStrings
        procedure, pass(string) :: concatCharsAndString
        procedure :: concatStringAndChars
        procedure :: concatStrings
        generic, public :: operator(.includes.) => stringIncludesString
        procedure :: stringIncludesString
        generic, public :: WRITE(FORMATTED) => stringWriteFormatted
        procedure :: stringWriteFormatted
    end type VegetableString_t

    type, public, abstract :: Maybe_t
    end type Maybe_t

    type, public, extends(Maybe_t) :: Nothing_t
    end type Nothing_t

    type, public :: Result_t
        private
        type(VegetableString_t) :: all_message
        type(VegetableString_t) :: failing_message
        integer :: num_failling_asserts
        integer :: num_passing_asserts
        logical :: passed_
    contains
        private
        generic, public :: operator(.and.) => combineResults
        procedure :: combineResults
        procedure, public :: failureDescription => resultFailureDescription
        procedure, public :: numAsserts => resultNumAsserts
        procedure, public :: numFailing => resultNumFailing
        procedure, public :: numPassing => resultNumPassing
        procedure, public :: passed => resultPassed
        procedure, public :: verboseDescription => resultVerboseDescription
    end type Result_t

    type, abstract, public :: Test_t
        private
        type(VegetableString_t) :: description_
    contains
        private
        procedure(testDescription), deferred, public :: description
        procedure(testNum), deferred, public :: numCases
    end type Test_t

    type, abstract, public :: TestResult_t
        private
        type(VegetableString_t) :: description
    contains
        private
        procedure(testQuestion), deferred, public :: failed
        procedure(testResultDescription), deferred, public :: failureDescription
        procedure(testResultNum), deferred, public :: numAsserts
        procedure(testResultNum), deferred, public :: numCases
        procedure(testResultNum), deferred, public :: numFailingAsserts
        procedure(testResultNum), deferred, public :: numFailingCases
        procedure(testResultNum), deferred, public :: numPassingAsserts
        procedure(testResultNum), deferred, public :: numPassingCases
        procedure(testQuestion), deferred, public :: passed
        procedure(testResultDescription), deferred, public :: verboseDescription
    end type TestResult_t

    type, public :: Transformed_t
        private
        class(*), allocatable :: value_
    end type Transformed_t

    abstract interface
        function inputTest(input) result(result_)
            import :: Result_t
            class(*), intent(in) :: input
            type(Result_t) :: result_
        end function inputTest

        function test_() result(result_)
            import :: Result_t
            type(Result_t) :: result_
        end function

        function testDescription(self) result(description)
            import :: Test_t, VegetableString_t
            class(Test_t), intent(in) :: self
            type(VegetableString_t) :: description
        end function testDescription

        pure function testNum(self) result(num)
            import :: Test_t
            class(Test_t), intent(in) :: self
            integer :: num
        end function testNum

        pure function testQuestion(self) result(answer)
            import :: TestResult_t
            class(TestResult_t), intent(in) :: self
            logical :: answer
        end function testQuestion

        function testResultDescription(self) result(description)
            import :: TestResult_t, VegetableString_t
            class(TestResult_t), intent(in) :: self
            type(VegetableString_t) :: description
        end function testResultDescription

        pure function testResultNum(self) result(num)
            import :: TestResult_t
            class(TestResult_t), intent(in) :: self
            integer :: num
        end function testResultNum

        function transformer_(input) result(output)
            import Transformed_t
            class(*), intent(in) :: input
            type(Transformed_t) :: output
        end function transformer_
    end interface

    type, public :: TestItem_t
        private
        class(Test_t), allocatable :: test
    contains
        private
        procedure, public :: description => testItemDescription
        procedure, public :: numCases => testItemNumCases
        procedure, public :: run => runTestItem
        procedure, public :: runWithInput => runTestItemWithInput
    end type TestItem_t

    type, extends(Test_t), public :: TestCase_t
        private
        procedure(test_), nopass, pointer :: test
    contains
        private
        procedure, public :: description => testCaseDescription
        procedure, public :: filter => filterTestCase
        procedure, public :: numCases => testCaseNumCases
        procedure, public :: run => runCase
    end type TestCase_t

    type, extends(Test_t), public :: InputTestCase_t
        private
        procedure(inputTest), nopass, pointer :: test
    contains
        private
        procedure, public :: description => inputTestCaseDescription
        procedure, public :: numCases => inputTestCaseNumCases
        procedure, public :: run => runCaseWithInput
    end type InputTestCase_t

    type, extends(Test_t), public :: TestCollection_t
        private
        type(TestItem_t), allocatable :: tests(:)
    contains
        private
        procedure, public :: description => testCollectionDescription
        procedure, public :: filter => filterTestCollection
        procedure, public :: numCases => testCollectionNumCases
        procedure, public :: run => runCollection
    end type TestCollection_t

    type, extends(Test_t), public :: TestCollectionWithInput_t
        private
        type(TestItem_t), allocatable :: tests(:)
        class(*), allocatable :: input
    contains
        private
        procedure, public :: description => testCollectionWithInputDescription
        procedure, public :: numCases => testCollectionWithInputNumCases
        procedure, public :: run => runCollectionThatHasInput
    end type TestCollectionWithInput_t

    type, extends(Test_t), public :: TransformingTestCollection_t
        private
        type(TestItem_t), allocatable :: tests(:)
        procedure(transformer_), nopass, pointer :: transformer
    contains
        private
        procedure, public :: description => transformingTestCollectionDescription
        procedure, public :: numCases => transformingTestCollectionNumCases
        procedure, public :: run => runTransformingCollection
    end type TransformingTestCollection_t

    type, public :: TestResultItem_t
        private
        class(TestResult_t), allocatable :: result_
    contains
        private
        procedure, public :: failureDescription => testResultItemFailureDescription
        procedure, public :: numAsserts => testResultItemNumAsserts
        procedure, public :: numCases => testResultItemNumCases
        procedure, public :: numFailingAsserts => testResultItemNumFailingAsserts
        procedure, public :: numFailingCases => testResultItemNumFailing
        procedure, public :: numPassingAsserts => testResultItemNumPassingAsserts
        procedure, public :: numPassingCases => testResultItemNumPassing
        procedure, public :: passed => testItemPassed
        procedure, public :: verboseDescription => testResultItemVerboseDescription
    end type TestResultItem_t

    type, extends(TestResult_t), public :: TestCaseResult_t
        private
        type(Result_t) :: result_
    contains
        private
        procedure, public :: failed => testCaseFailed
        procedure, public :: failureDescription => testCaseFailureDescription
        procedure, public :: numAsserts => testCaseNumAsserts
        procedure, public :: numCases => testCaseResultNumCases
        procedure, public :: numFailingAsserts => testCaseNumFailingAsserts
        procedure, public :: numFailingCases => testCaseNumFailing
        procedure, public :: numPassingAsserts => testCaseNumPassingAsserts
        procedure, public :: numPassingCases => testCaseNumPassing
        procedure, public :: passed => testCasePassed
        procedure, public :: verboseDescription => testCaseVerboseDescription
    end type TestCaseResult_t

    type, extends(TestResult_t), public :: TestCollectionResult_t
        private
        type(TestResultItem_t), allocatable :: results(:)
    contains
        private
        procedure, public :: failed => testCollectionFailed
        procedure, public :: failureDescription => testCollectionFailureDescription
        procedure, public :: numAsserts => testCollectionNumAsserts
        procedure, public :: numCases => testCollectionResultNumCases
        procedure, public :: numFailingAsserts => testCollectionNumFailingAsserts
        procedure, public :: numFailingCases => testCollectionNumFailing
        procedure, public :: numPassingAsserts => testCollectionNumPassingAsserts
        procedure, public :: numPassingCases => testCollectionNumPassing
        procedure, public :: passed => testCollectionPassed
        procedure, public :: verboseDescription => testCollectionVerboseDescription
    end type TestCollectionResult_t

    type :: Options_t
        private
        logical :: quiet
        logical :: verbose
    end type Options_t

    type, public, extends(Maybe_t) :: JustTestCase_t
        private
        type(TestCase_t) :: value_
    contains
        private
        procedure, public :: getValue => getValueTestCase
    end type JustTestCase_t

    interface assertDoesntInclude
        module procedure assertStringDoesntIncludeChars
        module procedure assertStringDoesntIncludeString
    end interface assertDoesntInclude

    interface assertEmpty
        module procedure assertEmptyChars
        module procedure assertEmptyString
    end interface assertEmpty

    interface assertEquals
        module procedure assertEqualsCharacterAndString
        module procedure assertEqualsCharacters
        module procedure assertEqualsInteger
    end interface assertEquals

    interface assertIncludes
        module procedure assertStringIncludesChars
        module procedure assertStringIncludesString
    end interface assertIncludes

    interface describe
        module procedure describeBasic
        module procedure describeWithInput
    end interface describe

    interface fail
        module procedure failWithChars
        module procedure failWithString
    end interface fail

    interface given
        module procedure givenBasic
        module procedure givenWithInput
    end interface given

    interface join
        module procedure joinWithCharacter
        module procedure joinWithString
    end interface join

    interface Just
        module procedure JustTestCase
    end interface Just

    interface splitAt
        module procedure splitAtBothCharacter
        module procedure splitAtStringCharacter
    end interface splitAt

    interface succeed
        module procedure succeedWithChars
        module procedure succeedWithString
    end interface succeed

    interface toString
        module procedure charsToString
        module procedure integerToString
    end interface toString

    interface when
        module procedure whenBasic
        module procedure whenWithInput
        module procedure whenWithTransformer
    end interface

    character(len=*), parameter :: NEWLINE = NEW_LINE('A')
    type(Nothing_t), parameter :: NOTHING = Nothing_t()

    public :: &
            assertDoesntInclude, &
            assertEmpty, &
            assertEquals, &
            assertIncludes, &
            assertNot, &
            assertThat, &
            describe, &
            fail, &
            given, &
            it, &
            it_, &
            runTests, &
            succeed, &
            TestCase, &
            TestCollection, &
            testThat, &
            then, &
            then_, &
            toString, &
            Transformed, &
            when
contains
    pure function assertEmptyChars(string) result(result__)
        character(len=*), intent(in) :: string
        type(Result_t) :: result__

        if (string == "") then
            result__ = succeed("String was empty")
        else
            result__ = fail("String '" // string // "' wasn't empty")
        end if
    end function assertEmptyChars

    pure function assertEmptyString(string) result(result__)
        type(VegetableString_t), intent(in) :: string
        type(Result_t) :: result__

        result__ = assertEmpty(string%string)
    end function assertEmptyString

    pure function assertEqualsCharacterAndString(expected, actual) result(result__)
        character(len=*), intent(in) :: expected
        type(VegetableString_t), intent(in) :: actual
        type(Result_t) :: result__

        result__ = assertEquals(expected, actual%string)
    end function assertEqualsCharacterAndString

    pure function assertEqualsCharacters(expected, actual) result(result__)
        character(len=*), intent(in) :: expected
        character(len=*), intent(in) :: actual
        type(Result_t) :: result__

        if (expected == actual) then
            result__ = succeed("Expected and got '" // toString(expected) // "'")
        else
            result__ = fail( &
                    "Expected '" // toString(expected) &
                    // "' but got '" // toString(actual) // "'")
        end if
    end function assertEqualsCharacters

    pure function assertEqualsInteger(expected, actual) result(result__)
        integer, intent(in) :: expected
        integer, intent(in) :: actual
        type(Result_t) :: result__

        if (expected == actual) then
            result__ = succeed("Expected and got '" // toString(expected) // "'")
        else
            result__ = fail( &
                    "Expected '" // toString(expected) &
                    // "' but got '" // toString(actual) // "'")
        end if
    end function assertEqualsInteger

    pure function assertNot(condition) result(result__)
        logical, intent(in) :: condition
        type(Result_t) :: result__

        if (.not. condition) then
            result__ = succeed("Was not true")
        else
            result__ = fail("Expected to not be true")
        end if
    end function assertNot

    pure function assertStringDoesntIncludeChars(search_for, string) result(result__)
        character(len=*), intent(in) :: search_for
        type(VegetableString_t), intent(in) :: string
        type(Result_t) :: result__

        result__ = assertDoesntInclude(toString(search_for), string)
    end function assertStringDoesntIncludeChars

    pure function assertStringDoesntIncludeString(search_for, string) result(result__)
        type(VegetableString_t), intent(in) :: search_for
        type(VegetableString_t), intent(in) :: string
        type(Result_t) :: result__

        if (.not.(string.includes.search_for)) then
            result__ = succeed( &
                    "'" // string // "' did not include '" // search_for // "'")
        else
            result__ = fail( &
                    "Expected '" // string &
                    // "' to not include '" // search_for // "'")
        end if
    end function assertStringDoesntIncludeString

    pure function assertStringIncludesChars(search_for, string) result(result__)
        character(len=*), intent(in) :: search_for
        type(VegetableString_t), intent(in) :: string
        type(Result_t) :: result__

        result__ = assertIncludes(toString(search_for), string)
    end function assertStringIncludesChars

    pure function assertStringIncludesString(search_for, string) result(result__)
        type(VegetableString_t), intent(in) :: search_for
        type(VegetableString_t), intent(in) :: string
        type(Result_t) :: result__

        if (string.includes.search_for) then
            result__ = succeed( &
                    "'" // string // "' included '" // search_for // "'")
        else
            result__ = fail( &
                    "Expected '" // string &
                    // "' to include '" // search_for // "'")
        end if
    end function assertStringIncludesString

    pure function assertThat(condition) result(result__)
        logical, intent(in) :: condition
        type(Result_t) :: result__

        if (condition) then
            result__ = succeed("Was true")
        else
            result__ = fail("Expected to be true")
        end if
    end function assertThat

    pure function charsToString(chars) result(string)
        character(len=*), intent(in) :: chars
        type(VegetableString_t) :: string

        string%string = chars
    end function charsToString

    pure function combineResults(lhs, rhs) result(combined)
        class(Result_t), intent(in) :: lhs
        type(Result_t), intent(in) :: rhs
        type(Result_t) :: combined

        combined = Result_( &
                all_message = lhs%all_message // NEWLINE // rhs%all_message, &
                failing_message = lhs%failing_message // NEWLINE // rhs%failing_message, &
                passed = lhs%passed_ .and. rhs%passed_, &
                num_failling_asserts = lhs%num_failling_asserts + rhs%num_failling_asserts, &
                num_passing_asserts = lhs%num_passing_asserts + rhs%num_passing_asserts)
    end function combineResults

    pure function concatCharsAndString(chars, string) result(combined)
        character(len=*), intent(in) :: chars
        class(VegetableString_t), intent(in) :: string
        type(VegetableString_t) :: combined

        combined = toString(chars // string%string)
    end function concatCharsAndString

    pure function concatStringAndChars(string, chars) result(combined)
        class(VegetableString_t), intent(in) :: string
        character(len=*), intent(in) :: chars
        type(VegetableString_t) :: combined

        combined = toString(string%string // chars)
    end function concatStringAndChars

    pure function concatStrings(lhs, rhs) result(combined)
        class(VegetableString_t), intent(in) :: lhs
        type(VegetableString_t), intent(in) :: rhs
        type(VegetableString_t) :: combined

        combined = toString(lhs%string // rhs%string)
    end function concatStrings

    pure function describeBasic(description, tests) result(test_collection)
        character(len=*), intent(in) :: description
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        allocate(TestCollection_t :: test_collection%test)
        select type (test => test_collection%test)
        type is (TestCollection_t)
            test = TestCollection(description, tests)
        end select
    end function describeBasic

    pure function describeWithInput(description, input, tests) result(test_collection)
        character(len=*), intent(in) :: description
        class(*), intent(in) :: input
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        allocate(TestCollectionWithInput_t :: test_collection%test)
        select type (test => test_collection%test)
        type is (TestCollectionWithInput_t)
            test = TestCollectionWithInput(description, input, tests)
        end select
    end function describeWithInput

    pure function failWithChars(message) result(failure)
        character(len=*), intent(in) :: message
        type(Result_t) :: failure

        failure = fail(toString(message))
    end function failWithChars

    pure function failWithString(message) result(failure)
        type(VegetableString_t), intent(in) :: message
        type(Result_t) :: failure

        failure = Result_( &
                passed = .false., &
                all_message = message, &
                failing_message = message, &
                num_failling_asserts = 1, &
                num_passing_asserts = 0)
    end function failWithString

    pure function filterTestCase(self, filter_string) result(maybe)
        class(TestCase_t), intent(in) :: self
        character(len=*), intent(in) :: filter_string
        class(Maybe_t), allocatable :: maybe

        if (self%description_.includes.toString(filter_string)) then
            maybe = Just(self)
        else
            maybe = NOTHING
        end if
    end function filterTestCase

    pure function filterTestCollection(self, filter_string) result(maybe)
        class(TestCollection_t), intent(in) :: self
        character(len=*), intent(in) :: filter_string
        class(Maybe_t), allocatable :: maybe

        associate(a => self, b => filter_string)
        end associate
        maybe = NOTHING
    end function filterTestCollection

    function getOptions() result(options)
        use iso_fortran_env, only: error_unit

        type(Options_t) :: options

        character(len=100) :: argument
        integer :: i
        integer :: num_arguments

        options%quiet = .false.
        options%verbose = .false.

        num_arguments = command_argument_count()
        i = 1
        do while (i <= num_arguments)
            call get_command_argument(i, argument)
            select case (trim(argument))
            case ("-q", "--quiet")
                options%quiet = .true.
            case ("-v", "--verbose")
                options%verbose = .true.
            case default
                write(error_unit, '(A)') &
                        "Unknown argument: '" // trim(argument) // "'"
                call exit(1)
            end select
            i = i + 1
        end do
    end function getOptions

    pure function getValueTestCase(just_) result(value_)
        class(JustTestCase_t), intent(in) :: just_
        type(TestCase_t) :: value_

        value_ = just_%value_
    end function getValueTestCase

    pure function givenBasic(description, tests) result(test_collection)
        character(len=*), intent(in) :: description
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        test_collection = describe("Given " // description, tests)
    end function givenBasic

    pure function givenWithInput(description, input, tests) result(test_collection)
        character(len=*), intent(in) :: description
        class(*), intent(in) :: input
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        test_collection = describe("Given " // description, input, tests)
    end function givenWithInput

    pure function hangingIndent(string_) result(indented)
        type(VegetableString_t), intent(in) :: string_
        type(VegetableString_t), allocatable :: indented

        type(VegetableString_t), allocatable :: lines(:)

        lines = splitAt(string_, NEWLINE)
        indented = join(lines, NEWLINE // "    ")
    end function hangingIndent

    function InputTestCase(description, func) result(test_case)
        character(len=*), intent(in) :: description
        procedure(inputTest) :: func
        type(InputTestCase_t) :: test_case

        test_case%description_ = toString(description)
        test_case%test => func
    end function InputTestCase

    pure function inputTestCaseDescription(self) result(description)
        class(InputTestCase_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%description_
    end function inputTestCaseDescription

    pure function inputTestCaseNumCases(self) result(num_cases)
        class(InputTestCase_t), intent(in) :: self
        integer :: num_cases

        associate(a => self)
        end associate
        num_cases = 1
    end function inputTestCaseNumCases

    pure function integerToString(int) result(string)
        integer, intent(in) :: int
        type(VegetableString_t) :: string

        character(len=12) :: temp

        write(temp, '(I0)') int
        string = toString(trim(temp))
    end function integerToString

    function it(description, func) result(test_case)
        character(len=*), intent(in) :: description
        procedure(test_) :: func
        type(TestItem_t) :: test_case

        allocate(TestCase_t :: test_case%test)
        select type (test => test_case%test)
        type is (TestCase_t)
            test = TestCase(description, func)
        end select
    end function it

    function it_(description, func) result(test_case)
        character(len=*), intent(in) :: description
        procedure(inputTest) :: func
        type(TestItem_t) :: test_case

        allocate(InputTestCase_t :: test_case%test)
        select type (test => test_case%test)
        type is (InputTestCase_t)
            test = InputTestCase(description, func)
        end select
    end function it_

    pure function joinWithCharacter(strings, separator) result(string)
        type(VegetableString_t), intent(in) :: strings(:)
        character(len=*), intent(in) :: separator
        type(VegetableString_t) :: string

        string = join(strings, toString(separator))
    end function joinWithCharacter

    pure function joinWithString(strings, separator) result(string)
        type(VegetableString_t), intent(in) :: strings(:)
        type(VegetableString_t), intent(in) :: separator
        type(VegetableString_t) :: string

        integer :: i

        string = strings(1)
        do i = 2, size(strings)
            string = string // separator // strings(i)
        end do
    end function joinWithString

    pure function JustTestCase(value_) result(just_)
        type(TestCase_t), intent(in) :: value_
        type(JustTestCase_t) :: just_

        just_ = JustTestCase_t(value_)
    end function JustTestCase

    pure function Result_(passed, all_message, failing_message, num_failling_asserts, num_passing_asserts)
        logical, intent(in) :: passed
        type(VegetableString_t), intent(in) :: all_message
        type(VegetableString_t), intent(in) :: failing_message
        integer, intent(in) :: num_failling_asserts
        integer, intent(in) :: num_passing_asserts
        type(Result_t) :: Result_

        Result_ = Result_t( &
                all_message = all_message, &
                failing_message = failing_message, &
                num_failling_asserts = num_failling_asserts, &
                num_passing_asserts = num_passing_asserts, &
                passed_ = passed)
    end function Result_

    pure function resultFailureDescription(self) result(description)
        class(Result_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%failing_message
    end function resultFailureDescription

    pure function resultNumAsserts(self) result(num_asserts)
        class(Result_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%num_passing_asserts + self%num_failling_asserts
    end function resultNumAsserts

    pure function resultNumFailing(self) result(num_asserts)
        class(Result_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%num_failling_asserts
    end function resultNumFailing

    pure function resultNumPassing(self) result(num_asserts)
        class(Result_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%num_passing_asserts
    end function resultNumPassing

    pure function resultPassed(self) result(passed)
        class(Result_t), intent(in) :: self
        logical :: passed

        passed = self%passed_
    end function resultPassed

    pure function resultVerboseDescription(self) result(description)
        class(Result_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%all_message
    end function resultVerboseDescription

    function runCase(self) result(result__)
        class(TestCase_t), intent(in) :: self
        type(TestCaseResult_t) :: result__

        result__ = TestCaseResult(self%description_, self%test())
    end function runCase

    function runCaseWithInput(self, input) result(result__)
        class(InputTestCase_t), intent(in) :: self
        class(*), intent(in) :: input
        type(TestCaseResult_t) :: result__

        result__ = TestCaseResult(self%description_, self%test(input))
    end function runCaseWithInput

    function runCollection(self) result(result__)
        class(TestCollection_t), intent(in) :: self
        type(TestCollectionResult_t) :: result__

        integer :: i
        integer :: num_tests
        type(TestResultItem_t), allocatable :: results(:)

        num_tests = size(self%tests)
        allocate(results(num_tests))
        do i = 1, num_tests
            results(i) = self%tests(i)%run()
        end do
        result__ = TestCollectionResult(self%description_, results)
    end function runCollection

    function runCollectionThatHasInput(self) result(result__)
        class(TestCollectionWithInput_t), intent(in) :: self
        type(TestCollectionResult_t) :: result__

        integer :: i
        integer :: num_tests
        type(TestResultItem_t), allocatable :: results(:)

        num_tests = size(self%tests)
        allocate(results(num_tests))
        do i = 1, num_tests
            results(i) = self%tests(i)%runWithInput(self%input)
        end do
        result__ = TestCollectionResult(self%description_, results)
    end function runCollectionThatHasInput

    function runTestItem(self) result(result_item)
        class(TestItem_t), intent(in) :: self
        type(TestResultItem_t) :: result_item

        select type (test => self%test)
        type is (TestCase_t)
            allocate(TestCaseResult_t :: result_item%result_)
            select type (result_ => result_item%result_)
            type is (TestCaseResult_t)
                result_ = test%run()
            end select
        type is (TestCollection_t)
            allocate(TestCollectionResult_t :: result_item%result_)
            select type (result_ => result_item%result_)
            type is (TestCollectionResult_t)
                result_ = test%run()
            end select
        type is (TestCollectionWithInput_t)
            allocate(TestCollectionResult_t :: result_item%result_)
            select type (result_ => result_item%result_)
            type is (TestCollectionResult_t)
                result_ = test%run()
            end select
        end select
    end function runTestItem

    function runTestItemWithInput(self, input) result(result_item)
        class(TestItem_t), intent(in) :: self
        class(*), intent(in) :: input
        type(TestResultItem_t) :: result_item

        select type (test => self%test)
        type is (InputTestCase_t)
            allocate(TestCaseResult_t :: result_item%result_)
            select type (result_ => result_item%result_)
            type is (TestCaseResult_t)
                result_ = test%run(input)
            end select
        type is (TransformingTestCollection_t)
            allocate(TestCollectionResult_t :: result_item%result_)
            select type (result_ => result_item%result_)
            type is (TestCollectionResult_t)
                result_ = test%run(input)
            end select
        end select
    end function runTestItemWithInput

    subroutine runTests(tests)
        use iso_fortran_env, only: error_unit, output_unit

        type(TestItem_t) :: tests

        type(Options_t) :: options
        type(TestResultItem_t) :: results

        options = getOptions()

        write(output_unit, '(A)') "Running Tests"
        write(output_unit, '(A)')
        if (.not.options%quiet) then
            write(output_unit, '(DT)') tests%description()
            write(output_unit, '(A)')
        end if
        write(output_unit, '(DT)') &
                "A total of " // toString(tests%numCases()) // " test cases"
        results = tests%run()
        if (results%passed()) then
            write(output_unit, '(A)')
            write(output_unit, '(A)') "All Passed"
            if (options%verbose) then
                write(output_unit, '(DT)') results%verboseDescription()
            end if
            write(output_unit, '(DT)') &
                    "A total of " // toString(results%numCases()) &
                    // " test cases containg a total of " &
                    // toString(results%numAsserts()) // " assertions"
            write(output_unit, '(A)')
        else
            write(error_unit, '(A)')
            write(error_unit, '(A)') "Failed"
            write(error_unit, '(A)')
            write(error_unit, '(DT)') &
                    toString(results%numFailingCases()) // " of " &
                    // toString(results%numCases()) // " cases failed"
            write(error_unit, '(DT)') &
                    toString(results%numFailingAsserts()) // " of " &
                    // toString(results%numAsserts()) // " assertions failed"
            write(error_unit, '(A)')
            if (options%verbose) then
                write(error_unit, '(DT)') results%verboseDescription()
            else
                write(error_unit, '(DT)') results%failureDescription()
            end if
            write(error_unit, '(A)')
            call exit(1)
        end if
    end subroutine

    function runTransformingCollection(self, input) result(result__)
        class(TransformingTestCollection_t), intent(in) :: self
        class(*), intent(in) :: input
        type(TestCollectionResult_t) :: result__

        integer :: i
        integer :: num_tests
        type(TestResultItem_t), allocatable :: results(:)
        type(Transformed_t) :: transformed

        transformed = self%transformer(input)
        select type (next_input => transformed%value_)
        type is (Result_t)
            allocate(results(1))
            allocate(TestCaseResult_t :: results(1)%result_)
            select type (the_result => results(1)%result_)
            type is (TestCaseResult_t)
                the_result = TestCaseResult(toString("Transformation Failed"), next_input)
            end select
            result__ = TestCollectionResult(self%description_, results)
        class default
            num_tests = size(self%tests)
            allocate(results(num_tests))
            do i = 1, num_tests
                results(i) = self%tests(i)%runWithInput(next_input)
            end do
            result__ = TestCollectionResult(self%description_, results)
        end select
    end function runTransformingCollection

    pure recursive function splitAtBothCharacter(&
            string_, split_characters) result(strings)
        character(len=*), intent(in) :: string_
        character(len=*), intent(in) :: split_characters
        type(VegetableString_t), allocatable :: strings(:)

        if (len(split_characters) > 0) then
            if (len(string_) > 0) then
                if (index(split_characters, string_(1:1)) > 0) then
                    strings = splitAtBothCharacter(string_(2:), split_characters)
                else if (index(split_characters, string_(len(string_):len(string_))) > 0) then
                    strings = splitAtBothCharacter(string_(1:len(string_) - 1), split_characters)
                else
                    strings = doSplit(string_, split_characters)
                end if
            else
                allocate(strings(1))
                strings(1) = toString("")
            end if
        else
            allocate(strings(1))
            strings(1) = toString(string_)
        end if
    contains
        pure function doSplit(string__, split_characters_) result(strings_)
            character(len=*), intent(in) :: string__
            character(len=*), intent(in) :: split_characters_
            type(VegetableString_t), allocatable :: strings_(:)

            integer :: i
            type(VegetableString_t), allocatable :: rest(:)
            character(len=:), allocatable :: this_string
            allocate(character(len=0)::this_string)

            do i = 2, len(string__)
                if (index(split_characters_, string__(i:i)) > 0) exit
            end do
            if (i < len(string__)) then
                this_string = string__(1:i - 1)
                rest = splitAtBothCharacter(string__(i + 1:), split_characters_)
                allocate(strings_(size(rest) + 1))
                strings_(1) = toString(this_string)
                strings_(2:) = rest(:)
            else
                allocate(strings_(1))
                strings_(1) = toString(string__)
            end if
        end function doSplit
    end function splitAtBothCharacter

    pure function splitAtStringCharacter(string_, split_characters) result(strings)
        type(VegetableString_t), intent(in) :: string_
        character(len=*), intent(in) :: split_characters
        type(VegetableString_t), allocatable :: strings(:)

        strings = splitAt(string_%string, split_characters)
    end function splitAtStringCharacter

    pure function stringIncludesString(string, search_for)
        class(VegetableString_t), intent(in) :: string
        type(VegetableString_t), intent(in) :: search_for
        logical :: stringIncludesString

        stringIncludesString = index(string%string, search_for%string) > 0
    end function stringIncludesString

    subroutine stringWriteFormatted(string, unit, iotype, v_list, iostat, iomsg)
        class(VegetableString_t), intent(in) :: string
        integer, intent(in) :: unit
        character(len=*), intent(in) :: iotype
        integer, intent(in) :: v_list(:)
        integer, intent(out) :: iostat
        character(len=*), intent(inout) :: iomsg

        associate(a => iotype, b => v_list); end associate

        write(unit=unit, iostat=iostat, iomsg=iomsg, fmt='(A)') string%string
    end subroutine stringWriteFormatted

    pure function succeedWithChars(message) result(success)
        character(len=*), intent(in) :: message
        type(Result_t) :: success

        success = succeed(toString(message))
    end function succeedWithChars

    pure function succeedWithString(message) result(success)
        type(VegetableString_t), intent(in) :: message
        type(Result_t) :: success

        success = Result_( &
                passed = .true., &
                all_message = message, &
                failing_message = toString(""), &
                num_failling_asserts = 0, &
                num_passing_asserts = 1)
    end function succeedWithString

    function TestCase(description, func) result(test_case)
        character(len=*), intent(in) :: description
        procedure(test_) :: func
        type(TestCase_t) :: test_case

        test_case%description_ = toString(description)
        test_case%test => func
    end function TestCase

    pure function testCaseDescription(self) result(description)
        class(TestCase_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%description_
    end function testCaseDescription

    pure function testCaseFailed(self) result(failed)
        class(TestCaseResult_t), intent(in) :: self
        logical :: failed

        failed = .not.self%passed()
    end function testCaseFailed

    pure function testCaseFailureDescription(self) result(description)
        class(TestCaseResult_t), intent(in) :: self
        type(VegetableString_t) :: description

        if (self%passed()) then
            description = toString("")
        else
            description = hangingIndent( &
                    self%description // NEWLINE // self%result_%failureDescription())
        end if
    end function testCaseFailureDescription

    pure function testCaseNumAsserts(self) result(num_asserts)
        class(TestCaseResult_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%result_%numAsserts()
    end function testCaseNumAsserts

    pure function testCaseNumCases(self) result(num_cases)
        class(TestCase_t), intent(in) :: self
        integer :: num_cases

        associate(a => self)
        end associate
        num_cases = 1
    end function testCaseNumCases

    pure function testCaseNumFailing(self) result(num_cases)
        class(TestCaseResult_t), intent(in) :: self
        integer :: num_cases

        if (self%passed()) then
            num_cases = 0
        else
            num_cases = 1
        end if
    end function testCaseNumFailing

    pure function testCaseNumFailingAsserts(self) result(num_asserts)
        class(TestCaseResult_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%result_%numFailing()
    end function testCaseNumFailingAsserts

    pure function testCaseNumPassing(self) result(num_cases)
        class(TestCaseResult_t), intent(in) :: self
        integer :: num_cases

        if (self%passed()) then
            num_cases = 1
        else
            num_cases = 0
        end if
    end function testCaseNumPassing

    pure function testCaseNumPassingAsserts(self) result(num_asserts)
        class(TestCaseResult_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%result_%numPassing()
    end function testCaseNumPassingAsserts

    pure function testCasePassed(self) result(passed)
        class(TestCaseResult_t), intent(in) :: self
        logical :: passed

        passed = self%result_%passed()
    end function testCasePassed

    pure function TestCaseResult(description, result__) result(test_case_result)
        type(VegetableString_t), intent(in) :: description
        type(Result_t), intent(in) :: result__
        type(TestCaseResult_t) :: test_case_result

        test_case_result%description = description
        test_case_result%result_ = result__
    end function TestCaseResult

    pure function testCaseResultNumCases(self) result(num_cases)
        class(TestCaseResult_t), intent(in) :: self
        integer :: num_cases

        associate(a => self)
        end associate
        num_cases = 1
    end function testCaseResultNumCases

    pure function testCaseVerboseDescription(self) result(description)
        class(TestCaseResult_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = hangingIndent( &
                self%description // NEWLINE // self%result_%verboseDescription())
    end function testCaseVerboseDescription

    pure function TestCollection(description, tests) result(test_collection)
        character(len=*), intent(in) :: description
        type(TestItem_t), intent(in) :: tests(:)
        type(TestCollection_t) :: test_collection

        test_collection%description_ = toString(description)
        allocate(test_collection%tests(size(tests)))
        test_collection%tests = tests
    end function TestCollection

    function testCollectionDescription(self) result(description)
        class(TestCollection_t), intent(in) :: self
        type(VegetableString_t) :: description

        type :: VegStringArray_t
            type(VegetableString_t), pointer :: strings(:) => null()
        end type VegStringArray_t

        integer, parameter :: MAX_STACK_SIZE = 100
        type(VegStringArray_t), save :: descriptions(MAX_STACK_SIZE)
        integer :: descriptions_location
        integer :: i
        integer :: num_cases

        num_cases = size(self%tests)
        do i = 1, MAX_STACK_SIZE
            if (.not.associated(descriptions(i)%strings)) then
                descriptions_location = i
                allocate(descriptions(descriptions_location)%strings(num_cases))
                exit
            end if
        end do
        if (i > MAX_STACK_SIZE) STOP "Test Collections Nested Too Deep!"
        do i = 1, num_cases
            descriptions(descriptions_location)%strings(i) = self%tests(i)%description()
        end do
        description = hangingIndent( &
                self%description_ // NEWLINE &
                // join(descriptions(descriptions_location)%strings, NEWLINE))
        deallocate(descriptions(descriptions_location)%strings)
        nullify(descriptions(descriptions_location)%strings)
    end function testCollectionDescription

    pure function testCollectionFailed(self) result(failed)
        class(TestCollectionResult_t), intent(in) :: self
        logical :: failed

        failed = .not.self%passed()
    end function testCollectionFailed

    function testCollectionFailureDescription(self) result(description)
        class(TestCollectionResult_t), intent(in) :: self
        type(VegetableString_t) :: description

        type :: VegStringArray_t
            type(VegetableString_t), pointer :: strings(:) => null()
        end type VegStringArray_t

        integer, parameter :: MAX_STACK_SIZE = 100
        type(VegStringArray_t), save :: descriptions(MAX_STACK_SIZE)
        integer :: descriptions_location
        integer :: i
        integer :: num_cases

        if (self%passed()) then
            description = toString("")
        else
            num_cases = size(self%results)
            do i = 1, MAX_STACK_SIZE
                if (.not.associated(descriptions(i)%strings)) then
                    descriptions_location = i
                    allocate(descriptions(descriptions_location)%strings(num_cases))
                    exit
                end if
            end do
            if (i > MAX_STACK_SIZE) STOP "Test Collections Nested Too Deep!"
            do i = 1, num_cases
                descriptions(descriptions_location)%strings(i) = self%results(i)%failureDescription()
            end do
            description = hangingIndent( &
                    self%description // NEWLINE &
                    // join(descriptions(descriptions_location)%strings, NEWLINE))
            deallocate(descriptions(descriptions_location)%strings)
            nullify(descriptions(descriptions_location)%strings)
        end if
    end function testCollectionFailureDescription

    pure function testCollectionNumAsserts(self) result(num_asserts)
        class(TestCollectionResult_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = sum(self%results%numAsserts())
    end function testCollectionNumAsserts

    pure function testCollectionNumCases(self) result(num_cases)
        class(TestCollection_t), intent(in) :: self
        integer :: num_cases

        num_cases = sum(self%tests%numCases())
    end function testCollectionNumCases

    pure function testCollectionNumFailing(self) result(num_cases)
        class(TestCollectionResult_t), intent(in) :: self
        integer :: num_cases

        num_cases = sum(self%results%numFailingCases())
    end function testCollectionNumFailing

    pure function testCollectionNumFailingAsserts(self) result(num_asserts)
        class(TestCollectionResult_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = sum(self%results%numFailingAsserts())
    end function testCollectionNumFailingAsserts

    pure function testCollectionNumPassing(self) result(num_cases)
        class(TestCollectionResult_t), intent(in) :: self
        integer :: num_cases

        num_cases = sum(self%results%numPassingCases())
    end function testCollectionNumPassing

    pure function testCollectionNumPassingAsserts(self) result(num_asserts)
        class(TestCollectionResult_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = sum(self%results%numPassingAsserts())
    end function testCollectionNumPassingAsserts

    pure function testCollectionPassed(self) result(passed)
        class(TestCollectionResult_t), intent(in) :: self
        logical :: passed

        passed = all(self%results%passed())
    end function testCollectionPassed

    pure function TestCollectionResult(description, results) result(test_collection_result)
        type(VegetableString_t), intent(in) :: description
        type(TestResultItem_t), intent(in) :: results(:)
        type(TestCollectionResult_t) :: test_collection_result

        test_collection_result%description = description
        allocate(test_collection_result%results(size(results)))
        test_collection_result%results = results
    end function TestCollectionResult

    pure function testCollectionResultNumCases(self) result(num_cases)
        class(TestCollectionResult_t), intent(in) :: self
        integer :: num_cases

        num_cases = sum(self%results%numCases())
    end function testCollectionResultNumCases

    function testCollectionVerboseDescription(self) result(description)
        class(TestCollectionResult_t), intent(in) :: self
        type(VegetableString_t) :: description

        type :: VegStringArray_t
            type(VegetableString_t), pointer :: strings(:) => null()
        end type VegStringArray_t

        integer, parameter :: MAX_STACK_SIZE = 100
        type(VegStringArray_t), save :: descriptions(MAX_STACK_SIZE)
        integer :: descriptions_location
        integer :: i
        integer :: num_cases

        num_cases = size(self%results)
        do i = 1, MAX_STACK_SIZE
            if (.not.associated(descriptions(i)%strings)) then
                descriptions_location = i
                allocate(descriptions(descriptions_location)%strings(num_cases))
                exit
            end if
        end do
        if (i > MAX_STACK_SIZE) STOP "Test Collections Nested Too Deep!"
        do i = 1, num_cases
            descriptions(descriptions_location)%strings(i) = self%results(i)%verboseDescription()
        end do
        description = hangingIndent( &
                self%description // NEWLINE &
                // join(descriptions(descriptions_location)%strings, NEWLINE))
        deallocate(descriptions(descriptions_location)%strings)
        nullify(descriptions(descriptions_location)%strings)
    end function testCollectionVerboseDescription

    pure function TestCollectionWithInput(description, input, tests) result(test_collection)
        character(len=*), intent(in) :: description
        class(*), intent(in) :: input
        type(TestItem_t), intent(in) :: tests(:)
        type(TestCollectionWithInput_t) :: test_collection

        test_collection%description_ = toString(description)
        test_collection%input = input
        allocate(test_collection%tests(size(tests)))
        test_collection%tests = tests
    end function TestCollectionWithInput

    function testCollectionWithInputDescription(self) result(description)
        class(TestCollectionWithInput_t), intent(in) :: self
        type(VegetableString_t) :: description

        type :: VegStringArray_t
            type(VegetableString_t), pointer :: strings(:) => null()
        end type VegStringArray_t

        integer, parameter :: MAX_STACK_SIZE = 100
        type(VegStringArray_t), save :: descriptions(MAX_STACK_SIZE)
        integer :: descriptions_location
        integer :: i
        integer :: num_cases

        num_cases = size(self%tests)
        do i = 1, MAX_STACK_SIZE
            if (.not.associated(descriptions(i)%strings)) then
                descriptions_location = i
                allocate(descriptions(descriptions_location)%strings(num_cases))
                exit
            end if
        end do
        if (i > MAX_STACK_SIZE) STOP "Test Collections Nested Too Deep!"
        do i = 1, num_cases
            descriptions(descriptions_location)%strings(i) = self%tests(i)%description()
        end do
        description = hangingIndent( &
                self%description_ // NEWLINE &
                // join(descriptions(descriptions_location)%strings, NEWLINE))
        deallocate(descriptions(descriptions_location)%strings)
        nullify(descriptions(descriptions_location)%strings)
    end function testCollectionWithInputDescription

    pure function testCollectionWithInputNumCases(self) result(num_cases)
        class(TestCollectionWithInput_t), intent(in) :: self
        integer :: num_cases

        num_cases = sum(self%tests%numCases())
    end function testCollectionWithInputNumCases

    function testItemDescription(self) result(description)
        class(TestItem_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%test%description()
    end function testItemDescription

    elemental function testItemNumCases(self) result(num_cases)
        class(TestItem_t), intent(in) :: self
        integer :: num_cases

        num_cases = self%test%numCases()
    end function testItemNumCases

    elemental function testItemPassed(self) result(passed)
        class(TestResultItem_t), intent(in) :: self
        logical :: passed

        passed = self%result_%passed()
    end function testItemPassed

    function testResultItemFailureDescription(self) result(description)
        class(TestResultItem_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%result_%failureDescription()
    end function testResultItemFailureDescription

    elemental function testResultItemNumAsserts(self) result(num_asserts)
        class(TestResultItem_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%result_%numAsserts()
    end function testResultItemNumAsserts

    elemental function testResultItemNumCases(self) result(num_cases)
        class(TestResultItem_t), intent(in) :: self
        integer :: num_cases

        num_cases = self%result_%numCases()
    end function testResultItemNumCases

    elemental function testResultItemNumFailing(self) result(num_cases)
        class(TestResultItem_t), intent(in) :: self
        integer :: num_cases

        num_cases = self%result_%numFailingCases()
    end function testResultItemNumFailing

    elemental function testResultItemNumFailingAsserts(self) result(num_asserts)
        class(TestResultItem_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%result_%numFailingAsserts()
    end function testResultItemNumFailingAsserts

    elemental function testResultItemNumPassing(self) result(num_cases)
        class(TestResultItem_t), intent(in) :: self
        integer :: num_cases

        num_cases = self%result_%numPassingCases()
    end function testResultItemNumPassing

    elemental function testResultItemNumPassingAsserts(self) result(num_asserts)
        class(TestResultItem_t), intent(in) :: self
        integer :: num_asserts

        num_asserts = self%result_%numPassingAsserts()
    end function testResultItemNumPassingAsserts

    function testResultItemVerboseDescription(self) result(description)
        class(TestResultItem_t), intent(in) :: self
        type(VegetableString_t) :: description

        description = self%result_%verboseDescription()
    end function testResultItemVerboseDescription

    pure function testThat(tests) result(test_collection)
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        allocate(TestCollection_t :: test_collection%test)
        select type (test => test_collection%test)
        type is (TestCollection_t)
            test = TestCollection("Test that", tests)
        end select
    end function testThat

    function then(description, func) result(test_case)
        character(len=*), intent(in) :: description
        procedure(test_) :: func
        type(TestItem_t) :: test_case

        test_case = it("Then " // description, func)
    end function then

    function then_(description, func) result(test_case)
        character(len=*), intent(in) :: description
        procedure(inputTest) :: func
        type(TestItem_t) :: test_case

        test_case = it_("Then " // description, func)
    end function then_

    pure function Transformed(input)
        class(*), intent(in) :: input
        type(Transformed_t) :: Transformed

        Transformed%value_ = input
    end function

    function TransformingTestCollection(description, func, tests) result(test_collection)
        character(len=*), intent(in) :: description
        procedure(transformer_) :: func
        type(TestItem_t), intent(in) :: tests(:)
        type(TransformingTestCollection_t) :: test_collection

        test_collection%description_ = toString(description)
        test_collection%transformer => func
        allocate(test_collection%tests(size(tests)))
        test_collection%tests = tests
    end function TransformingTestCollection

    function transformingTestCollectionDescription(self) result(description)
        class(TransformingTestCollection_t), intent(in) :: self
        type(VegetableString_t) :: description

        type :: VegStringArray_t
            type(VegetableString_t), pointer :: strings(:) => null()
        end type VegStringArray_t

        integer, parameter :: MAX_STACK_SIZE = 100
        type(VegStringArray_t), save :: descriptions(MAX_STACK_SIZE)
        integer :: descriptions_location
        integer :: i
        integer :: num_cases

        num_cases = size(self%tests)
        do i = 1, MAX_STACK_SIZE
            if (.not.associated(descriptions(i)%strings)) then
                descriptions_location = i
                allocate(descriptions(descriptions_location)%strings(num_cases))
                exit
            end if
        end do
        if (i > MAX_STACK_SIZE) STOP "Test Collections Nested Too Deep!"
        do i = 1, num_cases
            descriptions(descriptions_location)%strings(i) = self%tests(i)%description()
        end do
        description = hangingIndent( &
                self%description_ // NEWLINE &
                // join(descriptions(descriptions_location)%strings, NEWLINE))
        deallocate(descriptions(descriptions_location)%strings)
        nullify(descriptions(descriptions_location)%strings)
    end function transformingTestCollectionDescription

    pure function transformingTestCollectionNumCases(self) result(num_cases)
        class(TransformingTestCollection_t), intent(in) :: self
        integer :: num_cases

        num_cases = sum(self%tests%numCases())
    end function transformingTestCollectionNumCases

    pure function whenBasic(description, tests) result(test_collection)
        character(len=*), intent(in) :: description
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        test_collection = describe("When " // description, tests)
    end function whenBasic

    pure function whenWithInput(description, input, tests) result(test_collection)
        character(len=*), intent(in) :: description
        class(*), intent(in) :: input
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        test_collection = describe("When " // description, input, tests)
    end function whenWithInput

    function whenWithTransformer(description, func, tests) result(test_collection)
        character(len=*), intent(in) :: description
        procedure(transformer_) :: func
        type(TestItem_t), intent(in) :: tests(:)
        type(TestItem_t) :: test_collection

        allocate(TransformingTestCollection_t :: test_collection%test)
        select type (test => test_collection%test)
        type is (TransformingTestCollection_t)
            test = TransformingTestCollection("When " // description, func, tests)
        end select
    end function whenWithTransformer
end module Vegetables_m

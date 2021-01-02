module passing_case_test
    use example_asserts_m, only: NUM_ASSERTS_IN_PASSING, SUCCESS_MESSAGE
    use example_cases_m, only: example_passing_test_case, EXAMPLE_DESCRIPTION
    use helpers_m, only: test_item_input_t, test_result_item_input_t, run_test
    use vegetables, only: &
            input_t, &
            result_t, &
            test_item_t, &
            test_result_item_t, &
            assert_empty, &
            assert_equals, &
            assert_includes, &
            assert_that, &
            fail, &
            given, &
            then__, &
            when

    implicit none
    private

    public :: test_passing_case_behaviors
contains
    function test_passing_case_behaviors() result(test)
        type(test_item_t) :: test

        type(test_item_t) :: collection(1)
        type(test_item_input_t) :: the_case
        type(test_item_t) :: individual_tests(8)

        the_case = test_item_input_t(example_passing_test_Case())
        individual_tests(1) = then__("it knows it passed", check_case_passes)
        individual_tests(2) = then__("it has 1 test case", check_num_cases)
        individual_tests(3) = then__("it has no failing case", check_num_failing_cases)
        individual_tests(4) = then__("it's verbose description still includes the given description", check_verbose_description)
        individual_tests(5) = then__("it's verbose description includes the assertion message", check_verbose_description_assertion)
        individual_tests(6) = then__("it's failure description is empty", check_failure_description_empty)
        individual_tests(7) = then__("it knows how many asserts there were", check_num_asserts)
        individual_tests(8) = then__("it has no failing asserts", check_num_failing_asserts)
        collection(1) = when("it is run", run_test, individual_tests)
        test = given("a passing test case", the_case, collection)
    end function

    function check_case_passes(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_that(example_result%passed())
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_num_cases(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_equals(1, example_result%num_cases())
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_num_failing_cases(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_equals(0, example_result%num_failing_cases())
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_verbose_description(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_includes(EXAMPLE_DESCRIPTION, example_result%verbose_description(.false.))
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_verbose_description_assertion(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_includes(SUCCESS_MESSAGE, example_result%verbose_description(.false.))
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_failure_description_empty(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_empty(example_result%failure_description(.false.))
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_num_asserts(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_equals(NUM_ASSERTS_IN_PASSING, example_result%num_asserts())
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function

    function check_num_failing_asserts(input) result(result_)
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_result_item_t) :: example_result

        select type (input)
        type is (test_result_item_input_t)
            example_result = input%input()
            result_ = assert_equals(0, example_result%num_failing_asserts())
        class default
            result_ = fail("Expected to get a test_result_item_input_t")
        end select
    end function
end module

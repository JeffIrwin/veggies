module single_case_properties_test
    implicit none
    private

    public :: test_case_properties
contains
    function test_case_properties() result(test)
        use example_cases_m, only: example_passing_test_case
        use helpers_m, only: test_item_input_t
        use vegetables, only: test_item_t, describe, it_

        type(test_item_t) :: test

        type(test_item_t) :: individual_tests(3)
        type(test_item_input_t) :: the_case

        the_case = test_item_input_t(example_passing_test_case())
        individual_tests(1) = it_("includes the given description", check_case_description)
        individual_tests(2) = it_("only has 1 test case", check_num_cases)
        individual_tests(3) = it_("takes less than 3 times as long as the assertions to run", check_speed)
        test = describe("A test case", the_case, individual_tests)
    end function

    function check_case_description(input) result(result_)
        use example_cases_m, only: EXAMPLE_DESCRIPTION
        use helpers_m, only: test_item_input_t
        use vegetables, only: input_t, result_t, test_item_t, assert_includes, fail

        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_item_t) :: example_case

        select type (input)
        class is (test_item_input_t)
            example_case = input%input()
            result_ = assert_includes(EXAMPLE_DESCRIPTION, example_case%description())
        class default
            result_ = fail("Expected to get a test_item_input_t")
        end select
    end function

    function check_num_cases(input) result(result_)
        use helpers_m, only: test_item_input_t
        use vegetables, only: input_t, result_t, test_item_t, assert_equals, fail

        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_item_t) :: example_case

        select type (input)
        class is (test_item_input_t)
            example_case = input%input()
            result_ = assert_equals(1, example_case%num_cases())
        class default
            result_ = fail("Expected to get a test_item_input_t")
        end select
    end function

    function check_speed(input) result(result_)
        use helpers_m, only: test_item_input_t
        use vegetables, only: &
                input_t, result_t, test_item_t, assert_faster_than, fail

        class(input_t), intent(in) :: input
        type(result_t) :: result_

        type(test_item_t) :: internal_case

        select type (input)
        type is (test_item_input_t)
            internal_case = input%input()
            result_ = assert_faster_than(run_assertions, run_case, 100)
        class default
            result_ = fail("Expected to get a test_item_input_t")
        end select
    contains
        subroutine run_case
            use vegetables, only: test_result_item_t

            integer :: i
            type(test_result_item_t) :: internal_result

            do i = 1, 100
                internal_result = internal_case%run()
            end do
        end subroutine

        subroutine run_assertions
            use example_asserts_m, only: example_multiple_asserts
            use vegetables, only: result_t

            integer :: i
            type(result_t) :: result__

            do i = 1, 300
                result__ = example_multiple_asserts()
            end do
        end subroutine
    end function
end module

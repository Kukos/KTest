# KTEST - Kukos's Test Framework


### Getting started:
Before you use this framework I suggest to see, compile and play with examples which can be found in this repo (example directory)

To compile examples type:

````
$make all
````

or

````
$make example
````

## Features
* Good Verbose mode during assertions (both expect and assert) which can print every primitive variables using proper printf format
* Macros family with trivial relations (=, !=, <, <=, >, >=) and also macros for general condition
* Multi suite mode. You can run as many test suite (with several test cases) as you want in 1 binary file
* Parametrized test case. You can define every function as test case, so if you want to create parametrized test case, just pass function with arguments to TEST_CASE_RUN() macro
* Checking functions returned value in the same way as normal variable. You don't need to create temporary variable to pass to macro. Framework will analyze type of returned value and work on this as on normal variable
* Test case init and cleanup. You can define your own function to init and clean each test in test suite
* Fatal and non fatal assertion. Expect will continue test case after failure, assert will stop test case immediately after first failure
* Summary after each test suite which shows number of tests executed, passed, failed.
* State machine - to control framework flow, state machine has been created. If you use this framework in incorrect way, machine will show you what you did wrong

## Platforms
For now KTest has been tested only on Linux.

## Requirements
* Compiler with GnuC dialect and at least C11 standard
* Makefile

## How to build

You can type make help to get list of all targets:
````
KTest Makefile

Targets:
    all               - build ktest and examples
    lib               - build only ktest library
    examples          - examples
    install[P = Path] - install ktest to path P or default Path

Makefile supports Verbose mode when V=1
To check default compiler (gcc) change CC variable (i.e export CC=clang)
````
## How to install
To install KTest on your computer you can use

````
make install [P=path]
````
or you can execute script directly from

````
scripts/install_ktest.sh [P=path]
````

Let's assume that you have your project MyProject and directories as follows:
```
.
├── app
├── external
├── inc
├── src
└── tests
````

You want to install KTest in external/Ktest directory and use it in your unit tests under tests directory.

````
1. Download this repo
2. $make install P=/home/$user/MyProject/external/KTest
3 Now you need to link include files and libktest.a file, you can add to your compile this options
-I/home/$user/MyProject/external/KTest/inc -L/home/$user/MyProject/external/KTest -lktest
4. In your files you need include main header: #include <ktest/ktest.h>
5. Write test suite, test cases and enjoy! Please see examples for details.
````

## How to use
````c
/*
    1. Check examples :)
    2. INIT your test suite by using
        TEST_SUITE_INIT("My test name") or TEST_SUITE_INIT_WITH_FUNC("My test name", tc_init, tc_clean)
    3. Prepare test cases, this framework supports all kind of functions as test case,
        but please note, that framework wont use returned value.
        KTest supports also parametrized test case, you can create function with params like void f(int n).
        To test your functions (test case) pass function with parameters to macro TEST_CASE_RUN
        i.e TEST_CASE_RUN(f(10)), TEST_CASE_RUN(g())
    4. Finish your test suite to get statistics from KTest metadata using TEST_SUITE_SUMMARY()
    5. I suggest to return test suite status as a main return code, this framework supporst POSIX convection
        test suite status is equal 0 when entire suite pass  and non 0 value when suite failed.

    To create test cases you need a scenario wrapped into some function (with or without arguments).
    You need also a some assertions (checkpoints), to archive that you shall use
    T_EXPECT or T_ASSERT family.
    Please see macro description for better explanation.

    Framework supports multi file test suite, so you can split yours test suite to a few files,
    I suggest design as follows:
    test.c -> main file with TEST_SUITE_INIT and TEST_CASE_RUN + TEST_SUITE_SUMMARY
    test_subfile1.c -> file with test cases (functions with T_EXPECT / T_ASSERT)
    ...
    test_subfilen.c -> ....
    You can also put all code into 1 file like in an example, is not a problem. This is your decision.
    Please note that you can run several suites in 1 binary file. See examples for better understanding
*/

#include "ktest-priv.h"

/**
 *  Types for user (you can declare your own type, but function will be casted to this)
 */
typedef void tc_ret_t;


/**
 * Use this macro once per test suite, it will init all needed data
 * and print on stderr testsuite name in pretty format
 */
#define TEST_SUITE_INIT(suite_name) KTEST_TEST_SUITE_INIT(suite_name, NULL, NULL)

/**
 * Use this macro once per test suite, it will init all needed data
 * and print on stderr testsuite name in pretty format
 *
 * It will also set init and cleanup functions.
 * Init function will be called before every testcase
 * Cleanup function will be called after every testcase (if testcase ends)
 */
#define TEST_SUITE_INIT_WITH_FUNC(suite_name, tc_init, tc_clean) KTEST_TEST_SUITE_INIT(suite_name, tc_init, tc_clean)

/**
 * Use this macro once per test suite, it will finish test suite
 * and print on stderr all statistics about given testsuite
 */
#define TEST_SUITE_SUMMARY() KTEST_TEST_SUITE_SUMMARY()

/**
 * Use this macro to call passed function as a testcase.
 * TestCase should be tc_ret_t, but you can pass every function,
 * it can of another types returned value will be skipped.
 *
 * You can also preapre a parametrized test case,
 * this function supports functions with arguments
 *
 * use it as follows:
 * TEST_CASE_RUN(f());
 * TEST_CASE_RUN(g(100, 20, "some string"));
 */
#define TEST_CASE_RUN(function) KTEST_TEST_CASE_RUN(function)

/**
 * Use this macro to get test suite result in POSIX form.
 * 0 means test suite passed
 * >0 means test suite failed with X errors (X is the returned value)
 *
 * Please note that this functions remember only 1 testsuite
 * If you start another then prev value will be overwritten.
 * You can use this function after SUMMARY, because till another init
 * value will be keeped
 */
#define TEST_SUITE_GET_RESULT() KTEST_SUITE_GET_RESULT()

/**
 * Use this macros to check relation between 2 values
 * Macro supports functions, so you can pass non-void function as a value
 *
 * Also macros have compile time checking for types,
 * so rember to pass / cast values properly
 *
 * Relations:
 * EQ  -> val1 == val2
 * NEQ -> val1 != val2
 * LT  -> val1 <  val2
 * LEQ -> val1 <= val2
 * GT  -> val1 >  val2
 * GEQ -> val1 >= val2
 *
 * If condition (relation) is evaluated to false then test case
 * is marked as FAILED, on stderr proper print will be showed
 * and cpu will continue executing your funstion
 */
#define T_EXPECT_EQ(val, val2)  KTEST_EXPECT_EQ(val, val2)
#define T_EXPECT_NEQ(val, val2) KTEST_EXPECT_NEQ(val, val2)
#define T_EXPECT_GT(val, val2)  KTEST_EXPECT_GT(val, val2)
#define T_EXPECT_GEQ(val, val2) KTEST_EXPECT_GEQ(val, val2)
#define T_EXPECT_LT(val, val2)  KTEST_EXPECT_LT(val, val2)
#define T_EXPECT_LEQ(val, val2) KTEST_EXPECT_LEQ(val, val2)

/**
 * This macro is similar to T_EXCEPT_
 * but works with more complicated conditions.
 *
 * The main drawback is the print. Framework cannot split conditions to tokens
 * and chose proper printf format, so print will be "ugly"
 * Thats why I suggest to split code into several conditions.
 *
 * You can use this macro like this:
 * T_EXPECT(list != NULL && (list->head == NULL || list->size == 0))
 *
 */
#define T_EXPECT(cond)          KTEST_EXPECT_COND(cond)


/**
 * Those macros have the same functionality as T_EXCEPT
 * with 1 different thing.
 * When condition failed then cpu will stop executing your function
 * But wont stop entire test suite
 */
#define T_ASSERT_EQ(val, val2)  KTEST_ASSERT_EQ(val, val2)
#define T_ASSERT_NEQ(val, val2) KTEST_ASSERT_NEQ(val, val2)
#define T_ASSERT_GT(val, val2)  KTEST_ASSERT_GT(val, val2)
#define T_ASSERT_GEQ(val, val2) KTEST_ASSERT_GEQ(val, val2)
#define T_ASSERT_LT(val, val2)  KTEST_ASSERT_LT(val, val2)
#define T_ASSERT_LEQ(val, val2) KTEST_ASSERT_LEQ(val, val2)
#define T_ASSERT(cond)          KTEST_ASSERT_COND(cond)
````

## Example
````c
#include <ktest/ktest.h>

static tc_ret_t f(void);
static tc_ret_t g(int a);
static double double_add(double a, double b);

/* To show that we don't need a temporary variable */
static double double_add(double a, double b)
{
    return a + b;
}

static tc_ret_t f(void)
{
    T_EXPECT(0 < 1);
    T_EXPECT_EQ(0ul, 1ul);
    T_EXPECT_NEQ((short)1 , (short)1);
    T_EXPECT_GT((char)'A', (char)'Z');
    /* T_ASSERT(0 == 1); */
    T_EXPECT_GEQ((long double)2.78, (long double)3.14);
    T_EXPECT_LEQ(100.01, double_add(3.14, 2.78));
    T_EXPECT_LT((size_t)1, (size_t)0);
    T_EXPECT(0 == 1);
    T_ASSERT(0 == 1);
}

static tc_ret_t g(int a)
{
    T_EXPECT(a > 0);
    T_EXPECT_GT(a, 10);
    T_ASSERT_EQ(a, 11);
}

int main(void)
{
    /* f() will failed, to shows failed summary and verbose asserts  */
    TEST_SUITE_INIT("First testsuite");
    TEST_CASE_RUN(f());
    TEST_CASE_RUN(g(11));
    TEST_SUITE_SUMMARY();

    return TEST_SUITE_GET_RESULT();
}

````

#### Contact
email: michalkukowski10@gmail.com

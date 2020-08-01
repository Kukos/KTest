#include <stdio.h>
#include <ktest/ktest.h>

static double double_add(double a, double b);
static void tc_start(void);
static void tc_clean(void);

static double double_add(double a, double b)
{
    return a + b;
}

static void tc_start(void)
{
    printf("MY init\n");
}

static void tc_clean(void)
{
    printf("MY cleanup\n");
}

static tc_ret_t f(void);
static tc_ret_t g(int a);

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
    /* We need to keep thi valuie before another suite will start, because value will be overwritten */
    int result = TEST_SUITE_GET_RESULT();

    /* Let set also tc_init and tc_clean */
    TEST_SUITE_INIT_WITH_FUNC("Second testsuite", tc_start, tc_clean);
    TEST_CASE_RUN(g(11));
    TEST_CASE_RUN(g(11));
    TEST_SUITE_SUMMARY();
    result += TEST_SUITE_GET_RESULT();

    /* You can also set only one of functions  */
    TEST_SUITE_INIT_WITH_FUNC("Third testsuite", tc_start, NULL);
    TEST_CASE_RUN(g(11));
    TEST_SUITE_SUMMARY();

    return result + TEST_SUITE_GET_RESULT();
}

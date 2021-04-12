test_that("getting metadata works", {
  expect_error(get_md_cr(url = "https://www.google.com"))
  expect_type(get_md_cr(), "list")
})

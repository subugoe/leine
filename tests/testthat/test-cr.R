test_that("getting metadata works", {
  expect_error(get_md_cr_snap_m(url = "https://www.google.com"))
  expect_type(get_md_cr_snap_m(), "list")
})

test_that("stored metadata is still up to date", {
  expect_equal(
    md_cr_snaps_m(),
    get_md_cr_snaps_m()
  )
})

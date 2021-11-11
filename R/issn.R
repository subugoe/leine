#' @describeIn md_cr_snaps_m
#' Update the metadata of monthly snapshots stored in leine
update_issn <- function() {
  res <- get_md_cr_snaps_m()
  dput(
    res,
    file = system.file("checksums", "cr_snaps_md.R", package = "leine")
  )
  invisible(res)
}

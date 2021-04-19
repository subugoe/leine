# version ====

#' Metadata for Crossref monthly Snapshots
#' 
#' @description
#' Crossref releases dumps of their database on the 5th of every months.
#' These dumps sometimes change after the fact.
#' This metadata, stored in this package, 
#' locks down the versioning of the dumps for our analyses.
#' 
#' @details
#' To lock down the reproducibility of the metadata dumps,
#' we store their checksums in this package,
#' instead of merely relying on their *release date*.
#' (They have sometimes been updated in the past *after* release.)
#' 
#' Computing a checksum ourselves would be quite expensive
#' Gets metadata from the AWS S3 [response header](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html).
#' 
#' Happily, this works without authorisation for Metadata Plus.
#' 
#' Current monthly snapshots:
#' 
#' ```{r}
#' knitr::kable(md_cr_snaps_m())
#' ```
#' 
#' @family version
#' @family cr
#' @family lake
#' 
#' @export
md_cr_snaps_m <- function() {
  dget(file = system.file("checksums", "cr_snaps_md.R", package = "leine"))
}

#' @describeIn md_cr_snaps_m
#' Update the metadata of monthly snapshots stored in leine
update_md_cr_snaps_m <- function() {
  res <- get_md_cr_snaps_m()
  # TODO use datapasta for prettier output here again 
  # https://github.com/subugoe/leine/issues/16
  # datapasta::tribble_construct(res)
  dput(
    res,
    file = system.file("checksums", "cr_snaps_md.R", package = "leine")
  )
  invisible(res)
}

#' @describeIn md_cr_snaps_m 
#' Get metadata for currently available monthly snapshots
get_md_cr_snaps_m <- function() {
  purrr::map_dfr(
    get_md_cr_snaps_m_urls(),
    get_md_cr_snap_m,
    .id = "period"
  )
}

#' Get the metadata from the AWS S3 header response for *one* snapshot
#' @param url
#' The url to the snapshot as documented by Crossref.
#' Passed on to [httr::HEAD()].
#' @noRd
get_md_cr_snap_m <- function(url = "https://api.crossref.org/snapshots/monthly/latest/all.json.tar.gz") {
  res <- httr::RETRY(verb = "HEAD", url) %>%
    httr::stop_for_status() %>%
    httr::headers()
  if (res$server != "AmazonS3") {
    rlang::abort(c(
      "This function works only for AWS S3.",
      i = "Perhaps Crossref has changed their internal storage implementation."
    ))
  }
  list(
    url = url,
    date_modified = parse_date_time_aws(res[["last-modified"]]),
    etag = stringr::str_extract(res$etag, '(?<=\").*?(?=\")'),
    size = structure(as.numeric(res[["content-length"]]), class = "object_size")
  )
}

#' Translate datetime from AWS S3 header response to R
#' @noRd
parse_date_time_aws <- purrr::partial(
  lubridate::parse_date_time,
  orders = "a d b Y HMS",
  tz = "GMT"
)

#' Find all URLs to monthly cr snapshots up to now
#' @noRd
get_md_cr_snaps_m_urls <- function() {
  start <- lubridate::ymd("2018-04-06") # always supposed to come out on the 5th
  end <- lubridate::today()
  n_months_completed <- lubridate::interval(start, end) %/% months(1) - 1
  months_completed <- rep(start, n_months_completed)
  lubridate::month(months_completed) <- 
    lubridate::month(start) + c(1:n_months_completed)
  names(months_completed) <- format(months_completed, "%Y-%m")
  purrr::map_chr(
    months_completed,
    function(x) ym2cr_url(lubridate::year(x), format(x, "%Om"))
  )
}

#' Construct URLs to monthly cr snapshots
#' @param year,month year and month as character strings
#' @noRd
ym2cr_url <- function(y = "2018", m = "04") {
  base_url <- httr::parse_url("https://api.crossref.org/")
  base_url$path <- paste(
    "snapshots", "monthly", y, m, "all.json.tar.gz", sep = "/"
  )
  httr::build_url(base_url)
}

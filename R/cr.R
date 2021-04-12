# version ====

#' Get the metadata for a Crossref snapshot
#' 
#' @description
#' Gets metadata from the AWS S3 [response header](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html).
#' 
#' Happily, this works without authorisation for Metadata Plus.
#' 
#' @examples
#' get_md_cr()
#' 
#' @param url
#' The url to the snapshot as documented by Crossref.
#' Passed on to [httr::HEAD()].
#' 
#' @family version
#' @family cr
#' @family lake
#' 
#' @export
get_md_cr <- function(url = "https://api.crossref.org/snapshots/monthly/latest/all.json.tar.gz") {
  res <- httr::HEAD(url) %>%
    httr::stop_for_status() %>%
    httr::headers()
  if (res$server != "AmazonS3") {
    rlang::abort(c(
      "This function works only for AWS S3.",
      i = "Perhaps Crossref has changed their internal storage implementation."
    ))
  }
  parse_date_time_aws <- purrr::partial(
    lubridate::parse_date_time,
    orders = "a d b Y HMS",
    tz = "GMT"
  )

  list(
    date_retrieved = parse_date_time_aws(res$date),
    date_modified = parse_date_time_aws(res[["last-modified"]]),
    etag = stringr::str_extract(res$etag, '(?<=\").*?(?=\")'),
    size = structure(as.numeric(res[["content-length"]]), class = "object_size")
  )
}

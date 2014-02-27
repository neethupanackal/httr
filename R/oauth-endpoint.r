#' @include url.r
NULL

#' Describe an OAuth endpoint.
#'
#' See \code{\link{oauth_endpoints}} for a list of popular OAuth endpoints
#' baked into httr.
#'
#' @param request url used to request initial (unauthenticated) token.
#'   If using OAuth1.0, leave as \code{NULL}.
#' @param authorize url to send client to for authorisation
#' @param access url used to exchange unauthenticated for authenticated token.
#' @param ... other additional endpoints.
#' @param base_url option url to use as base for \code{request},
#'   \code{authorize} and \code{access} urls.
#' @family OAuth
#' @export
#' @examples
#' linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken",
#'   base_url = "https://api.linkedin.com/uas/oauth")
#' github <- oauth_endpoint(NULL, "authorize", "access_token",
#'   base_url = "https://github.com/login/oauth")
#' facebook <- oauth_endpoint(
#'   authorize = "https://www.facebook.com/dialog/oauth",
#'   access = "https://graph.facebook.com/oauth/access_token")
#'
#' oauth_endpoints
oauth_endpoint <- function(request = NULL, authorize, access, ...,
                           base_url = NULL) {
  urls <- list(request = request, authorize = authorize, access = access, ...)

  if (is.null(base_url)) {
    return(do.call(endpoint, urls))
  }

  # If base_url provided, add it as a prefix
  path <- parse_url(base_url)$path
  add_base_url <- function(x) {
    if (is.null(x)) return(x)
    if (substr(x, 1, 4) == "http") return(x)
    modify_url(base_url, path = file.path(path, x))
  }
  urls <- lapply(urls, add_base_url)
  do.call(endpoint, urls)
}
endpoint <- function(request, authorize, access, ...) {
  structure(list(request = request, authorize = authorize, access = access, ...),
    class = "oauth_endpoint")
}

is.oauth_endpoint <- function(x) inherits(x, "oauth_endpoint")

#' @export
print.oauth_endpoint <- function(x, ...) {
  x <- compact(x)
  cat("<oauth_endpoint>\n")
  cat(paste0(" ", format(paste0(names(x), ": ")), unlist(x), collapse = "\n"))
  cat("\n")
}

#' Popular oauth endpoints.
#'
#' This list provides some common OAuth endpoints.
#'
#' @export
oauth_endpoints <- list(
  linkedin = oauth_endpoint(
    base_url = "https://www.linkedin.com/uas/oauth2",
    authorize = "authorization",
    access = "accessToken",
  ),
  linkedin = oauth_endpoint(base_url = ,
    "requestToken", "authorization", "accessToken"),
  twitter = oauth_endpoint(base_url = "http://api.twitter.com/oauth",
    "request_token", "authenticate", "access_token"),
  vimeo = oauth_endpoint(base_url = "http://vimeo.com/oauth",
    "request_token", "authorize", "access_token"),
  google = oauth_endpoint(
    base_url = "https://accounts.google.com/o/oauth2",
    authorize = "auth",
    access = "token",
    validate = "https://www.googleapis.com/oauth2/v1/tokeninfo",
    revoke = "revoke"
  ),
  facebook = oauth_endpoint(
    authorize = "https://www.facebook.com/dialog/oauth",
    access = "https://graph.facebook.com/oauth/access_token"),
  github = oauth_endpoint(base_url = "https://github.com/login/oauth",
    NULL, "authorize", "access_token")
)

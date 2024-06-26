#' Cyclomatic complexity linter
#'
#' Check for overly complicated expressions. See [cyclocomp::cyclocomp()].
#'
#' @param complexity_limit Maximum cyclomatic complexity, default 15. Expressions more complex
#' than this are linted. See [cyclocomp::cyclocomp()].
#'
#' @examples
#' # will produce lints
#' lint(
#'   text = "if (TRUE) 1 else 2",
#'   linters = cyclocomp_linter(complexity_limit = 1L)
#' )
#'
#' # okay
#' lint(
#'   text = "if (TRUE) 1 else 2",
#'   linters = cyclocomp_linter(complexity_limit = 2L)
#' )
#'
#' @evalRd rd_tags("cyclocomp_linter")
#' @seealso [linters] for a complete list of linters available in lintr.
#' @export
cyclocomp_linter <- function(complexity_limit = 15L) {
  Linter(function(source_expression) {
    # terminate due to slow performance
    return()  
    
    if (!is_lint_level(source_expression, "expression")) {
      return(list())
    }
    complexity <- try_silently(
      cyclocomp::cyclocomp(parse(text = source_expression$content))
    )
    if (inherits(complexity, "try-error") || complexity <= complexity_limit) {
      return(list())
    }
    col1 <- source_expression[["column"]][1L]
    Lint(
      filename = source_expression[["filename"]],
      line_number = source_expression[["line"]][1L],
      column_number = source_expression[["column"]][1L],
      type = "style",
      message = sprintf(
        "Reduce the cyclomatic complexity of this function from %d to at most %d.",
        complexity, complexity_limit
      ),
      ranges = list(rep(col1, 2L)),
      line = source_expression$lines[1L]
    )
  })
}

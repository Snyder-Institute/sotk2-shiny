#### #### #### #### #### #### #### #### #### ####
# User settings

dataCol_default <- c("GLASS" = "cyan3", "IVYGAP" = "chartreuse1", "HEILAND" = "magenta")

seed         <- 1234
niter        <- 1000
commWeight   <- 100
cohortWeight <- 10

nodeSize      <- 10
nodeLabelSize <- 2
edgeAlpha     <- 0.8

.demo5_pieColors <- list(
        IVYGAP = c("CT" = "red", "IT" = "orange", "LE" = "gold", "MVP" = "darkslategray4", "PAN" = "burlywood4"),
        GLASS = list(
                sampleType = c("Primary" = "chartreuse1", "Recurrence" = "darkgreen"),
                molecularSubtype = c("Classical" = "deepskyblue2", "Mesenchymal" = "deeppink3", "Proneural" = "coral3")
        )
)

.demo6_colors <- list(
        GLASS = list(
                sampleType = c("Primary" = "chartreuse1", "Recurrence" = "darkgreen"),
                molecularSubtype = c("Classical" = "deepskyblue2", "Mesenchymal" = "deeppink3", "Proneural" = "coral3")
        ),
        IVYGAP = c("CT" = "red", "IT" = "orange", "LE" = "gold", "MVP" = "darkslategray4", "PAN" = "burlywood4")
)

#### #### #### #### #### #### #### #### #### ####
# User defined funcitons

# Parse rank strings like:
#   "3:10, 15, 20"
#   "3,4,5,6,7,8,9,10,15,20"
#   "5:30:5"  (interpreted as seq(5,30,by=5))
.usage_plot_paths <- function(dataset, rank) {
        rank_int <- suppressWarnings(as.integer(rank))
        if (is.na(rank_int)) rank_int <- rank

        rel_url <- file.path(
                "UsagePlot",
                dataset,
                paste0(dataset, "_usage_rank_", rank_int, ".png")
        )
        fs_path <- file.path("www", rel_url)

        return(list(rel_url = rel_url, fs_path = fs_path))
}

.list_available_ranks <- function(nmfObj) {
  if (is.null(nmfObj) || is.null(nmfObj$fit)) return(integer(0))

  fit <- nmfObj$fit
  ks <- if (is.environment(fit)) {
    suppressWarnings(as.integer(ls(fit)))
  } else if (is.list(fit)) {
    suppressWarnings(as.integer(names(fit)))
  } else {
    integer(0)
  }

  ks <- sort(ks[!is.na(ks)])
  return(ks)
}

.parse_rank_string <- function(x) {
        if (is.null(x) || !is.character(x) || length(x) != 1) {
                return(integer(0))
        }

        x <- gsub("\\s+", "", x)
        if (!nzchar(x)) {
                return(integer(0))
        }

        parts <- unlist(strsplit(x, ",", fixed = TRUE), use.names = FALSE)
        out <- integer(0)

        for (p in parts) {
                if (!nzchar(p)) next

                # pattern A: a:b:c -> seq(a, b, by=c)
                if (grepl("^-?\\d+:-?\\d+:-?\\d+$", p)) {
                        v <- as.integer(unlist(strsplit(p, ":", fixed = TRUE), use.names = FALSE))
                        a <- v[1]
                        b <- v[2]
                        by <- v[3]
                        if (by == 0) next
                        out <- c(out, seq(from = a, to = b, by = by))
                        next
                }

                # pattern B: a:b -> seq(a, b, by=1)
                if (grepl("^-?\\d+:-?\\d+$", p)) {
                        v <- as.integer(unlist(strsplit(p, ":", fixed = TRUE), use.names = FALSE))
                        out <- c(out, seq(from = v[1], to = v[2], by = 1))
                        next
                }

                # pattern C: single integer
                if (grepl("^-?\\d+$", p)) {
                        out <- c(out, as.integer(p))
                        next
                }

                # otherwise: invalid token
                return(NA_integer_)
        }

        out <- unique(out)
        out <- out[!is.na(out)]
        out <- sort(out)
        return(out)
}

.demo5_getIVYGAPidx <- function(x) {
        ctIdx <- c()
        itIdx <- c()
        leIdx <- c()
        mvpIdx <- c()
        panIdx <- c()

        if (!is.null(x)) {
                region <- stringr::str_sub(sapply(stringr::str_split(x, "__"), "[[", 2), 0, 3)
                ctIdx <- which(region == "Cel")
                itIdx <- which(region == "Inf")
                leIdx <- which(region == "Lea")
                mvpIdx <- which(region == "Mic")
                panIdx <- which(region == "Pse")
        }

        return(list(CT = ctIdx, IT = itIdx, LE = leIdx, MVP = mvpIdx, PAN = panIdx))
}

.demo5_getGLASSidx <- function(x, db) {
        priIdx <- c()
        recIdx <- c()
        claIdx <- c()
        mesIdx <- c()
        proIdx <- c()

        if (!is.null(x)) {
                sub <- db[which(rownames(db) %in% x), c("sample_type", "Subtype")]
                priIdx <- which(sub$sample_type == "Primary")
                recIdx <- which(sub$sample_type == "Recurrence")
                claIdx <- which(sub$Subtype == "Classical")
                mesIdx <- which(sub$Subtype == "Mesenchymal")
                proIdx <- which(sub$Subtype == "Proneural")
        }

        return(list(
                sampleType = list(Pri = priIdx, Rec = recIdx),
                molecularSubtype = list(Cla = claIdx, Mes = mesIdx, Pro = proIdx)
        ))
}

.demo6_geoMean <- function(x) {
        return(exp(mean(log(x))))
}

.demo6_getIVYGAPidx <- function(x) {
        ctIdx <- c()
        itIdx <- c()
        leIdx <- c()
        mvpIdx <- c()
        panIdx <- c()

        if (!is.null(x)) {
                region <- stringr::str_sub(sapply(stringr::str_split(x, "__"), "[[", 2), 0, 3)
                ctIdx <- which(region == "Cel")
                itIdx <- which(region == "Inf")
                leIdx <- which(region == "Lea")
                mvpIdx <- which(region == "Mic")
                panIdx <- which(region == "Pse")
        }

        return(list(CT = ctIdx, IT = itIdx, LE = leIdx, MVP = mvpIdx, PAN = panIdx))
}

.demo6_getGLASSidx <- function(x, db) {
        priIdx <- c()
        recIdx <- c()
        claIdx <- c()
        mesIdx <- c()
        proIdx <- c()

        if (!is.null(x)) {
                sub <- db[which(rownames(db) %in% x), c("sample_type", "Subtype")]
                priIdx <- which(sub$sample_type == "Primary")
                recIdx <- which(sub$sample_type == "Recurrence")
                claIdx <- which(sub$Subtype == "Classical")
                mesIdx <- which(sub$Subtype == "Mesenchymal")
                proIdx <- which(sub$Subtype == "Proneural")
        }

        return(list(
                sampleType = list(Pri = priIdx, Rec = recIdx),
                molecularSubtype = list(Cla = claIdx, Mes = mesIdx, Pro = proIdx)
        ))
}

.render_overview <- function(path = "overview.md") {
        if (!file.exists(path)) {
                return(shiny::HTML(paste0("<div style='color:#D66853;'>Missing file: ", path, "</div>")))
        }

        md_txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

        if (requireNamespace("commonmark", quietly = TRUE)) {
                html <- commonmark::markdown_html(
                        md_txt,
                        extensions = c("table", "strikethrough", "autolink")
                )
                return(shiny::HTML(html))
        }

        if (requireNamespace("markdown", quietly = TRUE)) {
                html <- markdown::markdownToHTML(
                        text = md_txt,
                        fragment.only = TRUE
                )
                return(shiny::HTML(html))
        }

        return(shiny::tags$pre(md_txt))
}

.render_md_file <- function(path) {
  if (!file.exists(path)) {
    return(shiny::HTML(paste0("<div style='color:#D66853;'>Missing file: ", path, "</div>")))
  }

  md_txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

  # Prefer commonmark (does NOT require the 'markdown' package)
  if (requireNamespace("commonmark", quietly = TRUE)) {
    html <- commonmark::markdown_html(
      md_txt,
      extensions = c("table", "strikethrough", "autolink")
    )
    return(shiny::HTML(html))
  }

  # Fallback to markdown::markdownToHTML if available
  if (requireNamespace("markdown", quietly = TRUE)) {
    html <- markdown::markdownToHTML(
      text = md_txt,
      fragment.only = TRUE
    )
    return(shiny::HTML(html))
  }

  return(tags$pre(md_txt))
}

message("Preset loaded.")

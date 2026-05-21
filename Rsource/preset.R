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

# Extract the per-step content from interpretation.md and transform it into
# a sidebar-friendly HTML block. The Interpretation tab uses .step-card /
# .step-table (a 2-column layout); the sidebar uses an independent set of
# classes (.sidebar-section etc.) defined in www/css/style.css. This keeps
# the two contexts fully decoupled — no cascade fights, no shared overrides.
.interpretation_step <- function(n, path = "interpretation.md") {
        if (!file.exists(path)) {
                return(shiny::HTML(""))
        }
        txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

        pieces <- strsplit(txt, '<div class="step-card">', fixed = TRUE)[[1]]
        if (length(pieces) < n + 1) {
                return(shiny::HTML(""))
        }
        card_inner <- pieces[[n + 1]]

        # Trim at the .step-card's closing </div>
        end_marker <- regexpr('\\n</div>\\s*\\n', card_inner)
        if (end_marker[[1]] > 0) {
                card_inner <- substr(card_inner, 1, end_marker[[1]] - 1)
        }

        # Drop the snapshot row entirely (image is shown next to the live plot).
        card_inner <- gsub(
                '(?s)<tr>\\s*<td colspan="2">\\s*<div class="step-snapshot">.*?</tr>',
                "",
                card_inner,
                perl = TRUE
        )

        # Pull out the step title text. Pattern: <div class="step-title">TEXT</div>
        title <- ""
        m <- regmatches(card_inner, regexpr('<div class="step-title">[^<]*</div>', card_inner))
        if (length(m) > 0) {
                title <- sub('<div class="step-title">([^<]*)</div>', '\\1', m)
        }

        # Strip the title div + the <table class="step-table">...</table> wrappers,
        # leaving the bare <tr>/<td> structure to transform.
        card_inner <- sub('<div class="step-title">[^<]*</div>', '', card_inner)
        card_inner <- gsub('<table class="step-table">', '', card_inner, fixed = TRUE)
        card_inner <- gsub('</table>', '', card_inner, fixed = TRUE)
        card_inner <- gsub('<tbody>|</tbody>', '', card_inner)

        # Each <td>...</td> becomes a <div class="sidebar-section">; rows collapse.
        card_inner <- gsub('<tr>|</tr>', '', card_inner)
        card_inner <- gsub('<td[^>]*>', '<div class="sidebar-section">', card_inner)
        card_inner <- gsub('</td>', '</div>', card_inner)

        # Rename the pill classes so styling is independent of the Interpretation tab.
        card_inner <- gsub(
                'class="cell-head cell-rep"',
                'class="sidebar-section-head sidebar-rep"',
                card_inner, fixed = TRUE
        )
        card_inner <- gsub(
                'class="cell-head cell-look"',
                'class="sidebar-section-head sidebar-look"',
                card_inner, fixed = TRUE
        )
        card_inner <- gsub(
                'class="cell-head cell-use"',
                'class="sidebar-section-head sidebar-use"',
                card_inner, fixed = TRUE
        )
        card_inner <- gsub(
                'class="cell-head cell-note"',
                'class="sidebar-section-head sidebar-note"',
                card_inner, fixed = TRUE
        )

        # Drop the .ul-tight class (sidebar has its own ul/li margins).
        card_inner <- gsub('class="ul-tight"', '', card_inner, fixed = TRUE)

        html <- paste0(
                '<div class="sidebar-interp">',
                '<div class="sidebar-step-card">',
                if (nzchar(title)) paste0('<div class="sidebar-step-title">', title, '</div>'),
                card_inner,
                '</div></div>'
        )
        shiny::HTML(html)
}

.lite_banner_html <- function() {
        paste(
                '<div style="border-left: 4px solid #D66853; background: #fff7f3; padding: 14px 18px; border-radius: 8px; margin: 16px 0;">',
                '  <div style="font-weight: 600; color: #D66853; margin-bottom: 6px;">',
                '    You are viewing the LITE deployment',
                '  </div>',
                '  <div style="font-size: 13px; color: #4d4d4d; line-height: 1.55;">',
                '    This public instance displays a <b>precomputed analysis</b> of the demo cohorts for fast, safe browsing. ',
                '    Recompute controls (correlation method, datasets, threshold, community detection algorithm, rewiring weights) are disabled. ',
                '    Display-only controls such as labels, node size, and annotation pickers remain interactive.',
                '    <br /><br />',
                '    To run the <b>full interactive version</b> &mdash; every input live, recompute on demand &mdash; use the public Docker image on your own machine:',
                '    <pre style="background: #ffffff; border: 1px solid #f0d8cc; padding: 10px 12px; border-radius: 6px; margin: 10px 0; font-size: 12px; white-space: pre-wrap;">docker run --rm -p 11630:11630 -e SOTK2_MODE=full thebiohub/sotk2:latest</pre>',
                '    Then open <a href="http://localhost:11630" target="_blank" rel="noopener noreferrer">http://localhost:11630</a>. ',
                '    See <a href="https://github.com/Snyder-Institute/sotk2-docker" target="_blank" rel="noopener noreferrer">Snyder-Institute/sotk2-docker</a> for build details and a launcher script that auto-opens the browser.',
                '  </div>',
                '</div>',
                sep = "\n"
        )
}

.render_overview <- function(lite, path = "overview.md") {
        if (!file.exists(path)) {
                return(shiny::HTML(paste0("<div style='color:#D66853;'>Missing file: ", path, "</div>")))
        }

        md_txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
        banner <- if (isTRUE(lite)) .lite_banner_html() else ""
        md_txt <- sub("<!--LITE_BANNER-->", banner, md_txt, fixed = TRUE)

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

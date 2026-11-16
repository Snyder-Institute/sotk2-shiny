#### #### #### #### #### #### #### #### #### ####
# App: sotk2 demo Shiny app
# Author: Heewon Seo (Heewon.Seo@ucalgary.ca)
# Date: December 27, 2025
#### #### #### #### #### #### #### #### #### ####
# Theme colors
## Dark blue  - #404f7c
## Light blue - #85dafa
## Grey       - #4d4d4d
## Red point  - #D66853
#### #### #### #### #### #### #### #### #### ####
# Load libraries
library(shiny)
library(sotk2)

#### #### #### #### #### #### #### #### #### ####
# Global settings / data
source("./Rsource/preset.R")

# Precomputed SOTK object (recommended for default display)
data_dir <- "data"
soObj_path <- file.path(data_dir, "soObj.RDS")
soObj <- if (file.exists(soObj_path)) readRDS(soObj_path) else NULL

nmf_paths <- list(
        GLASS   = file.path(data_dir, "nmfRes_GLASS.RDS"),
        IVYGAP  = file.path(data_dir, "nmfRes_IVYGAP.RDS"),
        HEILAND = file.path(data_dir, "nmfRes_HEILAND.RDS")
)

#### #### #### #### #### #### #### #### #### ####
# UI
ui <- navbarPage(
        title = div(
                "sotk2",
                style = "color:white; font-size:24px; font-weight:bold; font-style: italic;"
        ),
        id = "navbar",
        selected = "Overview",
        fluid = TRUE,
        collapsible = TRUE,
        footer = includeHTML("footer.html"),
        header = tags$head(
                tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
                tags$link(rel = "shortcut icon", href = "imgs/favicon.ico"),
                tags$head(includeHTML("ga.html")),
                tags$script(HTML("
                        (function() {
                        var PLOT_IDS = ['demo1_corr_density', 'demo2_network', 'demo3_network', 'demo4_network', 'demo5_comm_network', 'demo6_geomean_plot'];                        function setSquareForId(id) {
                        var el = document.getElementById(id);
                        if (!el) return false;

                        var w = el.getBoundingClientRect().width;
                        if (!w || w < 50) return false;

                        el.style.height = w + 'px';
                        return true;
                        }

                        function setSquares() {
                        var anyOk = false;
                        for (var i = 0; i < PLOT_IDS.length; i++) {
                        anyOk = setSquareForId(PLOT_IDS[i]) || anyOk;
                        }
                        return anyOk;
                        }

                        function setSquaresWithRetry(maxTries, delayMs) {
                        var tries = 0;
                        function attempt() {
                        tries += 1;
                        var ok = setSquares();
                        if (!ok && tries < maxTries) {
                                setTimeout(attempt, delayMs);
                        }
                        }
                        attempt();
                        }

                        // Run early + retry while layout stabilizes
                        document.addEventListener('DOMContentLoaded', function() {
                        setSquaresWithRetry(30, 50);
                        });

                        // After Shiny connects and after it becomes idle
                        document.addEventListener('shiny:connected', function() {
                        setSquaresWithRetry(30, 50);
                        });

                        document.addEventListener('shiny:idle', function() {
                        setSquaresWithRetry(10, 50);
                        });

                        // Window resize
                        window.addEventListener('resize', function() {
                        setSquares();
                        });

                        // Bootstrap tab change: when any tab (navbar or tabsetPanel)
                        // becomes visible, dispatch a resize so Shiny re-renders the
                        // plot at the now-correct container size, then re-square.
                        if (window.jQuery) {
                        jQuery(document).on('shown.bs.tab', function() {
                        window.dispatchEvent(new Event('resize'));
                        setSquaresWithRetry(10, 50);
                        });
                        }

                        // Observe DOM mutations inside each plot output (e.g., img/canvas inserted)
                        function attachMutationObserver(id) {
                        var el = document.getElementById(id);
                        if (!el || typeof MutationObserver === 'undefined') return;

                        var mo = new MutationObserver(function() {
                        setSquaresWithRetry(5, 30);
                        });

                        mo.observe(el, { childList: true, subtree: true });
                        }

                        // Observe size changes (best-effort)
                        function attachResizeObserver(id) {
                        var el = document.getElementById(id);
                        if (!el || typeof ResizeObserver === 'undefined') return;

                        var ro = new ResizeObserver(function() {
                        setSquareForId(id);
                        });
                        ro.observe(el);
                        }

                        document.addEventListener('DOMContentLoaded', function() {
                        for (var i = 0; i < PLOT_IDS.length; i++) {
                        attachMutationObserver(PLOT_IDS[i]);
                        attachResizeObserver(PLOT_IDS[i]);
                        }
                        });
                        })();
                        "))
        ),

        #-#-#- Home
        tabPanel(
                title = "Overview",
                tags$div(
                        class = "page-content",
                        .render_overview()
                )
        ),

        #-#-#- Usage
        tabPanel(
                title = "Usage",
                h2("Usage (H) matrices from cNMF runs"),
                fluidPage(
                        fluidRow(
                                column(
                                        width = 12,
                                        helpText(
                                                "The usage plot corresponds to the H (usage) matrix from an NMF factorization. ",
                                                "Rows represent gene expression programs (GEPs) and columns represent samples; ",
                                                "an annotation track above the heatmap indicates sample-level metadata where available, ",
                                                "and cell values encode program usage weights. ",
                                                "Note that cNMF refers to these components as GEPs, whereas standard NMF often uses the term metagenes; ",
                                                "the two terms are used interchangeably here."
                                        )
                                )
                        ),
                        fluidRow(
                                column(
                                        width = 5,
                                        radioButtons(
                                                inputId = "usageDataset",
                                                label = h3("Data:"),
                                                choices = c("GLASS", "IVYGAP"),
                                                selected = "GLASS"
                                        )
                                ),
                                column(
                                        width = 5,
                                        numericInput(
                                                inputId = "usageRank",
                                                label = h3("Rank:"),
                                                value = 5,
                                                min = 3,
                                                max = 60,
                                                step = 1
                                        ),
                                        helpText("Select a rank between 3 and 60.")
                                )
                        ),
                        fluidRow(
                                column(
                                        width = 12,
                                        h3("Usage plot"),
                                        uiOutput("usagePlotOutput"),
                                        tags$br(),
                                        tags$div(
                                                style = "color: #666666; font-size: 12px;",
                                                tags$b("Interpretation: "),
                                                "Use this heatmap as a sanity check to identify potential outliers and to assess sample clustering by shared program usage. ",
                                                "Compare usage-driven clusters with sample annotations (e.g., Verhaak subtype, primary vs. recurrence, tumor purity), ",
                                                "as these patterns typically correspond to correlation structure used downstream by sotk2."
                                        ),
                                        tags$br()
                                )
                        )
                )
        ),

        #-#-#- Tutorial
        tabPanel(
                "Tutorial",
                sidebarLayout(
                        sidebarPanel(
                                width = 3,

                                # Step selector is the tabsetPanel id below (input.demos_step)
                                conditionalPanel(
                                        condition = "input.demos_step == 'Step 1'",
                                        tags$div(
                                                style = "color:#4d4d4d; font-size: 12px;",
                                                "Alert: adjusting the options below may take time."
                                        ),
                                        tags$br(),
                                        selectInput(
                                                inputId = "demo1_cor_method",
                                                label = "Correlation method",
                                                choices = c("Spearman" = "spearman", "Pearson" = "pearson"),
                                                selected = "spearman"
                                        ),
                                        checkboxGroupInput(
                                                inputId = "demo1_datasets",
                                                label = "Datasets to include",
                                                choices = c("GLASS", "IVYGAP", "HEILAND"),
                                                selected = c("GLASS", "IVYGAP", "HEILAND")
                                        )
                                ),
                                conditionalPanel(
                                        condition = "input.demos_step == 'Step 2'",
                                        numericInput(
                                                inputId = "demo2_coef_thre",
                                                label = "Correlation coefficient threshold",
                                                value = 0.3,
                                                min = -1,
                                                max = 1,
                                                step = 0.1
                                        ),
                                        radioButtons(
                                                inputId = "demo2_label",
                                                label = "Show labels",
                                                choices = c("FALSE" = "FALSE", "TRUE" = "TRUE"),
                                                selected = "FALSE"
                                        )
                                ),
                                conditionalPanel(
                                        condition = "input.demos_step == 'Step 3'",
                                        selectInput(
                                                inputId = "demo3_search_met",
                                                label = "Community detection algorithm",
                                                choices = c(
                                                        "Fast greedy" = "greedy",
                                                        "Leiden" = "leiden",
                                                        "Betweenness" = "betweenness",
                                                        "Random walk" = "randomwalk",
                                                        "Eigen" = "eigen",
                                                        "Louvain" = "louvain"
                                                ),
                                                selected = "greedy"
                                        ),
                                        radioButtons(
                                                inputId = "demo3_label",
                                                label = "Show labels",
                                                choices = c("FALSE" = "FALSE", "TRUE" = "TRUE"),
                                                selected = "FALSE"
                                        ),
                                        numericInput(
                                                inputId = "demo3_node_size",
                                                label = "Node size",
                                                value = 10,
                                                min = 1,
                                                step = 1
                                        ),
                                        numericInput(
                                                inputId = "demo3_node_label_size",
                                                label = "Node label size",
                                                value = 2,
                                                min = 0,
                                                step = 1
                                        ),
                                        sliderInput(
                                                inputId = "demo3_edge_alpha",
                                                label = "Edge alpha",
                                                value = 0.8,
                                                min = 0,
                                                max = 1,
                                                step = 0.1
                                        )
                                ),
                                conditionalPanel(
                                        condition = "input.demos_step == 'Step 4'",
                                        radioButtons(
                                                inputId = "demo4_label",
                                                label = "Label",
                                                choices = c("FALSE" = "FALSE", "TRUE" = "TRUE"),
                                                selected = "FALSE"
                                        ),
                                        radioButtons(
                                                inputId = "demo4_annot",
                                                label = "Annotation",
                                                choices = c("Community" = "community", "Cohort" = "cohort"),
                                                selected = "community"
                                        ),
                                        numericInput(
                                                inputId = "demo4_comm_weight",
                                                label = "Community rewiring weight ",
                                                value = 100,
                                                min = 10,
                                                max = 100,
                                                step = 10
                                        ),
                                        numericInput(
                                                inputId = "demo4_cohort_weight",
                                                label = "Cohort rewiring weight ",
                                                value = 10,
                                                min = 10,
                                                max = 100,
                                                step = 10
                                        )
                                ),
                                conditionalPanel(
                                        condition = "input.demos_step == 'Step 5'",
                                        selectInput(
                                                inputId = "demo5_annot_type",
                                                label = "Annotation",
                                                choices = c(
                                                        "Layout" = "layout",
                                                        "GLASS (primary vs. recurrence)" = "glass_sampletype",
                                                        "GLASS (molecular subtype)" = "glass_verhaak",
                                                        "IVYGAP (anatomical features)" = "ivygap"
                                                ),
                                                selected = "layout"
                                        )
                                ),
                                conditionalPanel(
                                        condition = "input.demos_step == 'Step 6'",
                                        selectInput(
                                                inputId = "demo6_cohort",
                                                label = "Cohort",
                                                choices = c("GLASS", "IVYGAP"),
                                                selected = "GLASS"
                                        ),
                                        uiOutput("demo6_comm_ui"),
                                        tags$hr(),
                                        downloadButton(
                                                outputId = "demo6_download_soObj",
                                                label = "Download soObj.RDS"
                                        ),
                                        tags$div(
                                                style = "color:#4d4d4d; font-size: 12px; margin-top: 6px;",
                                                "This exports the most recent soObj object used to generate the tutorial figures."
                                        )
                                )
                        ),
                        mainPanel(
                                tabsetPanel(
                                        id = "demos_step",
                                        tabPanel(
                                                "Step 1",
                                                h3("Examine correlation structure"),
                                                tags$div(
                                                        class = "sq-plot-wrap",
                                                        plotOutput("demo1_corr_density", width = "100%")
                                                ),
                                                tags$br(),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Interpretation: "),
                                                        "Diagonal panels summarize within-dataset correlation distributions; lower-left panels summarize between-dataset correlations. ",
                                                        "The upper-right reference panels provide overall coefficient distributions for comparison. ",
                                                        "These distributions can guide the selection of correlation thresholds for network construction in subsequent steps."
                                                ),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Note: "),
                                                        "In this tutorial, rank grids are fixed to match the precomputed cNMF objects distributed with the demo data. ",
                                                        "For GLASS and IVYGAP (bulk RNA-seq), we use ranks 3–10 plus 15 and 20. ",
                                                        "For HEILAND (Visium v1), the input matrix is comparatively sparse, and we therefore use a coarser grid (5, 10, 15, 20, 25, 30) rather than an exhaustive set of ranks."
                                                )
                                        ),
                                        tabPanel(
                                                "Step 2",
                                                h3("Construct the correlation network"),
                                                tags$div(
                                                        class = "sq-plot-wrap",
                                                        plotOutput("demo2_network", width = "100%")
                                                ),
                                                tags$br(),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Interpretation: "),
                                                        "Edges represent correlations between metagenes retained after applying coefThre. ",
                                                        "This panel shows an unweighted network (weighted = FALSE) annotated by cohort (annot = 'cohort'). ",
                                                        "Toggle labels to inspect individual nodes (GEPs); adjust coefThre to control network sparsity."
                                                )
                                        ),
                                        tabPanel(
                                                "Step 3",
                                                h3("Detect communities"),
                                                tags$div(
                                                        class = "sq-plot-wrap",
                                                        plotOutput("demo3_network", width = "100%")
                                                ),
                                                tags$br(),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Interpretation: "),
                                                        "Communities are identified using the selected community detection algorithm (searchMet) and nodes are annotated by their assigned community (annot = 'community'). ",
                                                        "Adjust node size, label size, and edge transparency to improve readability. ",
                                                        "These display settings affect visualization only and do not modify the underlying correlation structure or community assignments."
                                                )
                                        ),
                                        tabPanel(
                                                "Step 4",
                                                h3("Refine network layout for interpretation"),
                                                tags$div(
                                                        class = "sq-plot-wrap",
                                                        plotOutput("demo4_network", width = "100%")
                                                ),
                                                tags$br(),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Interpretation: "),
                                                        "This panel visualizes the weighted layout (weighted = TRUE). ",
                                                        "Select the annotation level (community or cohort) and toggle labels for inspection. ",
                                                        "commWeight and cohortWeight control visualization-focused edge rewiring and do not affect community detection."
                                                )
                                        ),
                                        tabPanel(
                                                "Step 5",
                                                h3("Summarize communities at the module level"),
                                                tags$div(
                                                        class = "sq-plot-wrap",
                                                        plotOutput("demo5_comm_network", width = "100%")
                                                ),
                                                tags$br(),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Interpretation: "),
                                                        "This panel summarizes the network at the community level, where each node represents a community and edges represent inter-community connectivity. ",
                                                        "Node size reflects the number of GEPs (metagenes) assigned to the community, and edge thickness summarizes the extent of connectivity between communities (i.e., the number of inter-community edges in the underlying metagene network). ",
                                                        "When an annotation option is selected, each community node is overlaid with a pie chart that summarizes the enrichment or depletion of sample annotations among metagenes assigned to that community. ",
                                                        "Pie slices correspond to annotation categories (e.g., primary vs. recurrence, molecular subtype, or anatomical region), and slice magnitudes represent standardized chi-squared residuals. ",
                                                        "Positive residuals indicate over-representation relative to expectation, whereas negative residuals indicate under-representation, enabling comparison of annotation-specific association patterns across communities."
                                                )
                                        ),
                                        tabPanel(
                                                "Step 6",
                                                h3("Community-level GEP usage (geometric mean)"),
                                                tags$div(
                                                        class = "sq-plot-wrap",
                                                        plotOutput("demo6_geomean_plot", width = "100%")
                                                ),
                                                tags$br(),
                                                tags$div(
                                                        style = "color:#4d4d4d; font-size: 12px;",
                                                        tags$b("Interpretation: "),
                                                        "For the selected cohort and community, this panel summarizes per-sample community activity using the geometric mean of metagene usage values. ",
                                                        "Curves show empirical cumulative distribution functions (ECDFs) stratified by available sample annotations ",
                                                        "(GLASS: primary vs. recurrence and molecular subtype; IVYGAP: anatomical region). ",
                                                        "Comparing ECDFs across strata can help distinguish communities with relatively stronger or weaker activity in specific biological contexts."
                                                )
                                        )
                                )
                        )
                )
        ),

        #-#-#- Interpretation
        tabPanel(
                title = "Interpretation",
                tags$div(class = "page-content", shiny::includeMarkdown("interpretation.md"))
        ),
)

#### #### #### #### #### #### #### #### #### ####
# Server
server <- function(input, output, session) {
        output$usagePlotOutput <- renderUI({
                paths <- .usage_plot_paths(input$usageDataset, input$usageRank)

                if (file.exists(paths$fs_path)) {
                        HTML(paste0(
                                "<a href=\"", paths$rel_url, "\" target=\"_blank\" rel=\"noopener noreferrer\">",
                                "<img src=\"", paths$rel_url, "\" width=\"100%\">",
                                "</a>",
                                "<br />",
                                "<span style=\"color: grey;\">Click the image to enlarge in a new tab.</span>"
                        ))
                } else {
                        HTML("<span style=\"color: red;\">Image not available. Select another rank.</span>")
                }
        })

        # ---- Demos: Step 1.
        # Cache NMF objects (read each nmfRes_*.RDS only once per session)
        .get_nmf_obj_cached <- local({
                cache <- new.env(parent = emptyenv())

                function(dataset, data_dir = "data") {
                        if (exists(dataset, envir = cache, inherits = FALSE)) {
                                return(get(dataset, envir = cache, inherits = FALSE))
                        }

                        p <- file.path(data_dir, paste0("nmfRes_", dataset, ".RDS"))
                        if (!file.exists(p)) {
                                return(NULL)
                        }

                        obj <- readRDS(p)
                        assign(dataset, obj, envir = cache)
                        return(obj)
                }
        })

        demo1_last_error <- reactiveVal(NULL)
        demo1_initial_inputs <- reactiveVal(NULL)

        # Fixed rank grids (match demo data)
        demo1_rank_fixed <- list(
                GLASS   = c(3:10, 15, 20),
                IVYGAP  = c(3:10, 15, 20),
                HEILAND = seq(5, 30, 5)
        )

        observe({
                req(input$demo1_cor_method, input$demo1_datasets)

                if (is.null(demo1_initial_inputs())) {
                        demo1_initial_inputs(list(
                                cor_method = input$demo1_cor_method,
                                datasets   = input$demo1_datasets
                        ))
                }
        })

        demo1_inputs_changed <- reactive({
                init <- demo1_initial_inputs()
                if (is.null(init)) {
                        return(FALSE)
                }

                same_method <- identical(input$demo1_cor_method, init$cor_method)
                same_sets <- setequal(input$demo1_datasets, init$datasets)

                return(!(same_method && same_sets))
        })

        demo1_soSet <- reactive({
                demo1_last_error(NULL)

                if (!demo1_inputs_changed()) {
                        if (is.null(soObj) || is.null(soObj@SOSet)) {
                                demo1_last_error("ERROR: soObj@SOSet is not available. Please confirm data/soObj.RDS contains an SOSet.")
                                return(NULL)
                        }
                        return(soObj@SOSet)
                }

                ds <- input$demo1_datasets
                if (is.null(ds) || length(ds) == 0) {
                        demo1_last_error("ERROR: Please select at least one dataset.")
                        return(NULL)
                }

                rankL <- demo1_rank_fixed[ds]

                dataL <- list()
                missing_ds <- character(0)

                for (d in ds) {
                        obj <- .get_nmf_obj_cached(d, data_dir = data_dir)
                        if (is.null(obj)) {
                                missing_ds <- c(missing_ds, d)
                        } else {
                                dataL[[d]] <- obj
                        }
                }

                if (length(missing_ds) > 0) {
                        demo1_last_error(
                                paste0(
                                        "ERROR: Missing nmfRes_*.RDS under ./", data_dir, " for: ",
                                        paste(missing_ds, collapse = ", "),
                                        "."
                                )
                        )
                        return(NULL)
                }

                dataCol <- dataCol_default[ds]

                out <- tryCatch(
                        sotk2::SOSet(
                                NMFobjL   = dataL,
                                NMFrankL  = rankL,
                                dataCol   = dataCol,
                                corMet    = input$demo1_cor_method
                        ),
                        error = function(e) e
                )

                if (inherits(out, "error")) {
                        demo1_last_error(paste0("ERROR: SOSet() failed: ", conditionMessage(out)))
                        return(NULL)
                }

                return(out)
        })

        output$demo1_corr_density <- renderPlot({
                soSet <- demo1_soSet()
                req(soSet)
                sotk2::plotCorrDensity(soSet, filename = NULL)
        })
        #### -- End of Step 1.

        # ---- Step 2.
        demo2_last_error <- reactiveVal(NULL)

        demo2_soObj <- reactive({
                demo2_last_error(NULL)


                if (!demo1_inputs_changed() &&
                        isTRUE(all.equal(input$demo2_coef_thre, 0.3)) &&
                        !is.null(soObj)) {
                        return(soObj)
                }

                soSet <- demo1_soSet()
                req(soSet)

                out <- tryCatch(
                        {
                                sotk2::SOTK(
                                        SOSet = soSet,
                                        coefThre = input$demo2_coef_thre,
                                        seed = seed,
                                        niter = niter,
                                        commWeight = commWeight,
                                        cohortWeight = cohortWeight
                                )
                        },
                        error = function(e) e
                )

                if (inherits(out, "error")) {
                        demo2_last_error(paste0("ERROR: SOTK() failed: ", conditionMessage(out)))
                        return(NULL)
                }

                return(out)
        })

        output$demo2_network <- renderPlot({
                soObj2 <- demo2_soObj()
                req(soObj2)

                label_flag <- suppressWarnings(as.logical(input$demo2_label))
                if (is.na(label_flag)) label_flag <- TRUE

                sotk2::plotNetwork(
                        soObj2,
                        label = label_flag,
                        annot = "cohort",
                        edgeAlpha = edgeAlpha,
                        weighted = FALSE,
                        filename = NULL,
                        vertexSize = nodeSize,
                        vertexLabelCex = nodeLabelSize
                )
        })
        #### -- End of Step 2.

        # ---- Step 3.

        demo3_last_error <- reactiveVal(NULL)

        demo3_soObj <- reactive({
                demo3_last_error(NULL)


                searchMet <- input$demo3_search_met
                if (is.null(searchMet) || !(searchMet %in% c("greedy", "leiden", "betweenness", "randomwalk", "eigen", "louvain"))) {
                        searchMet <- "greedy"
                }

                if (identical(searchMet, "greedy")) {
                        return(demo2_soObj())
                }

                soSet <- demo1_soSet()
                req(soSet)

                coefThre <- suppressWarnings(as.numeric(input$demo2_coef_thre))
                if (is.null(coefThre) || is.na(coefThre)) coefThre <- 0.3

                out <- tryCatch(
                        {
                                sotk2::SOTK(
                                        SOSet = soSet,
                                        coefThre = coefThre,
                                        seed = seed,
                                        niter = niter,
                                        commWeight = commWeight,
                                        cohortWeight = cohortWeight,
                                        searchMet = searchMet
                                )
                        },
                        error = function(e) e
                )

                if (inherits(out, "error")) {
                        demo3_last_error(paste0("ERROR: SOTK() failed: ", conditionMessage(out)))
                        return(NULL)
                }

                return(out)
        })

        output$demo3_network <- renderPlot({
                demo3_last_error(NULL)

                soObj3 <- demo3_soObj()
                req(soObj3)

                nodeSize_use <- suppressWarnings(as.numeric(input$demo3_node_size))
                if (is.na(nodeSize_use) || nodeSize_use <= 0) nodeSize_use <- 10

                nodeLabelSize_use <- suppressWarnings(as.numeric(input$demo3_node_label_size))
                if (is.na(nodeLabelSize_use) || nodeLabelSize_use < 0) nodeLabelSize_use <- 2

                edgeAlpha_use <- suppressWarnings(as.numeric(input$demo3_edge_alpha))
                if (is.na(edgeAlpha_use) || edgeAlpha_use < 0 || edgeAlpha_use > 1) edgeAlpha_use <- 0.8

                label_flag <- suppressWarnings(as.logical(input$demo3_label))
                if (is.na(label_flag)) label_flag <- FALSE

                tryCatch(
                        {
                                sotk2::plotNetwork(
                                        soObj3,
                                        label = label_flag,
                                        annot = "community",
                                        edgeAlpha = edgeAlpha_use,
                                        weighted = FALSE,
                                        filename = NULL,
                                        vertexSize = nodeSize_use,
                                        vertexLabelCex = nodeLabelSize_use
                                )
                        },
                        error = function(e) {
                                demo3_last_error(paste0("ERROR: plotNetwork() failed: ", conditionMessage(e)))
                                return(NULL)
                        }
                )
        })
        #### -- End of Step 3.

        # ---- Step 4.
        demo4_last_error <- reactiveVal(NULL)

        demo4_soObj <- reactive({
        demo4_last_error(NULL)


        cw <- suppressWarnings(as.numeric(input$demo4_comm_weight))
        hw <- suppressWarnings(as.numeric(input$demo4_cohort_weight))
        if (is.null(cw) || is.na(cw)) cw <- 100
        if (is.null(hw) || is.na(hw)) hw <- 10

        coefThre <- suppressWarnings(as.numeric(input$demo2_coef_thre))
        if (is.null(coefThre) || is.na(coefThre)) coefThre <- 0.3

        # NEW: carry forward searchMet from Step 3
        searchMet <- input$demo3_search_met
        if (is.null(searchMet) || !(searchMet %in% c("greedy", "leiden", "betweenness", "randomwalk", "eigen", "louvain"))) {
                searchMet <- "greedy"
        }

        # Use precomputed object only when *all* SOTK-relevant settings match defaults,
        # including the community detection method.
        if (!is.null(soObj) &&
            !demo1_inputs_changed() &&
            isTRUE(all.equal(coefThre, 0.3)) &&
            isTRUE(all.equal(cw, 100)) &&
            isTRUE(all.equal(hw, 10)) &&
            identical(searchMet, "greedy")) {
                return(soObj)
        }

        soSet <- demo1_soSet()
        req(soSet)

        out <- tryCatch(
                {
                        sotk2::SOTK(
                                SOSet = soSet,
                                coefThre = coefThre,
                                seed = seed,
                                niter = niter,
                                commWeight = cw,
                                cohortWeight = hw,
                                searchMet = searchMet   # NEW
                        )
                },
                error = function(e) e
        )

        if (inherits(out, "error")) {
                demo4_last_error(paste0("ERROR: SOTK() failed: ", conditionMessage(out)))
                return(NULL)
        }

        return(out)
})

        output$demo4_network <- renderPlot({
                demo4_last_error(NULL)

                soObj4 <- demo4_soObj()
                req(soObj4)

                label_flag <- suppressWarnings(as.logical(input$demo4_label))
                if (is.null(label_flag) || is.na(label_flag)) label_flag <- FALSE

                annot_choice <- input$demo4_annot
                if (is.null(annot_choice) || !(annot_choice %in% c("community", "cohort"))) {
                        annot_choice <- "community"
                }

                tryCatch(
                        {
                                sotk2::plotNetwork(
                                        soObj4,
                                        label = label_flag,
                                        annot = annot_choice,
                                        edgeAlpha = edgeAlpha,
                                        weighted = TRUE,
                                        filename = NULL,
                                        vertexSize = nodeSize,
                                        vertexLabelCex = nodeLabelSize
                                )
                        },
                        error = function(e) {
                                demo4_last_error(paste0("ERROR: plotNetwork() failed: ", conditionMessage(e)))
                                return(NULL)
                        }
                )
        })
        #### -- End of Step 4.

        # ---- Step 5.
        demo5_last_error <- reactiveVal(NULL)

        demo5_vertexInfo <- reactive({
                demo5_last_error(NULL)

                # Dependencies
                if (!requireNamespace("igraph", quietly = TRUE)) {
                        demo5_last_error("ERROR: igraph is required for Step 5 (install.packages('igraph')).")
                        return(NULL)
                }
                if (!requireNamespace("stringr", quietly = TRUE)) {
                        demo5_last_error("ERROR: stringr is required for Step 5 (install.packages('stringr')).")
                        return(NULL)
                }

                # Use the most up-to-date soObj available in your app.
                soObj5 <- demo4_soObj()
                req(soObj5)

                annot_type <- input$demo5_annot_type
                if (is.null(annot_type) || !(annot_type %in% c("layout", "glass_sampletype", "glass_verhaak", "ivygap"))) {
                        annot_type <- "layout"
                }

                # Layout only
                if (identical(annot_type, "layout")) {
                        return(NULL)
                }

                # Core objects from soObj
                corNetwork <- soObj5@corNetwork
                commNetwork <- soObj5@commNetwork
                clusterMembership <- soObj5@sample2metagene
                community <- seq_len(length(soObj5@commCols))

                allGEPs <- data.frame(
                        Data = sapply(stringr::str_split(igraph::V(corNetwork)$name, "\\$"), "[[", 1),
                        GEP = igraph::V(corNetwork)$name,
                        Community = igraph::V(corNetwork)$community,
                        stringsAsFactors = FALSE
                )

                # Utility to initialize vertexInfo containers
                .init_vertexInfo <- function(legend_vec) {
                        vertexLabel <- rep("", length(community))
                        names(vertexLabel) <- community
                        vertexSize <- rep(0.1, length(community))
                        names(vertexSize) <- community
                        vertexPie <- rep_len(list(numeric(length(legend_vec))), length(community))
                        names(vertexPie) <- paste0("Community_", community)
                        return(list(vertexLabel = vertexLabel, vertexSize = vertexSize, vertexPie = vertexPie))
                }

                # GLASS: sample type 
                if (identical(annot_type, "glass_sampletype")) {
                        annot_path <- file.path(data_dir, "annot_GLASS.RDS")
                        if (!file.exists(annot_path)) {
                                demo5_last_error("ERROR: annot_GLASS.RDS not found under ./data. Please download it (required for GLASS annotations).")
                                return(NULL)
                        }
                        glassAnnot <- readRDS(annot_path)

                        dName <- "GLASS"
                        if (is.null(clusterMembership[[dName]])) {
                                demo5_last_error("ERROR: GLASS is not present in soObj@sample2metagene. Confirm GLASS was included in the analysis.")
                                return(NULL)
                        }

                        legend <- names(.demo5_pieColors$GLASS$sampleType)
                        legendCol <- .demo5_pieColors$GLASS$sampleType

                        init <- .init_vertexInfo(legend)
                        vertexLabel <- init$vertexLabel
                        vertexSize <- init$vertexSize
                        vertexPie <- init$vertexPie

                        cl <- clusterMembership[[dName]]
                        subGEPs <- allGEPs[which(allGEPs$Data == dName), , drop = FALSE]

                        for (whichComm in community) {
                                commName <- paste0("Community_", whichComm)
                                commSpecificGEPs <- subGEPs[which(subGEPs$Community == whichComm), , drop = FALSE]
                                if (nrow(commSpecificGEPs) > 0) {
                                        allSamples <- c()
                                        for (gep in commSpecificGEPs$GEP) allSamples <- c(allSamples, cl[[gep]])
                                        idx <- .demo5_getGLASSidx(unique(allSamples), glassAnnot)
                                        noSamples <- sapply(idx$sampleType, length)

                                        if (sum(noSamples) != 0) {
                                                vertexPie[[commName]] <- noSamples
                                                vertexSize[whichComm] <- igraph::V(commNetwork)$size[whichComm]
                                                vertexLabel[whichComm] <- igraph::V(commNetwork)$name[whichComm]
                                        }
                                }
                        }

                        return(list(
                                vertexLabel = vertexLabel,
                                vertexSize  = vertexSize,
                                vertexPie   = vertexPie,
                                legend      = legend,
                                legendCol   = legendCol
                        ))
                }

                # GLASS: Verhaak (molecular subtype)
                if (identical(annot_type, "glass_verhaak")) {
                        annot_path <- file.path(data_dir, "annot_GLASS.RDS")
                        if (!file.exists(annot_path)) {
                                demo5_last_error("ERROR: annot_GLASS.RDS not found under ./data. Please download it (required for GLASS annotations).")
                                return(NULL)
                        }
                        glassAnnot <- readRDS(annot_path)

                        dName <- "GLASS"
                        if (is.null(clusterMembership[[dName]])) {
                                demo5_last_error("ERROR: GLASS is not present in soObj@sample2metagene. Confirm GLASS was included in the analysis.")
                                return(NULL)
                        }

                        legend <- names(.demo5_pieColors$GLASS$molecularSubtype)
                        legendCol <- .demo5_pieColors$GLASS$molecularSubtype

                        init <- .init_vertexInfo(legend)
                        vertexLabel <- init$vertexLabel
                        vertexSize <- init$vertexSize
                        vertexPie <- init$vertexPie

                        cl <- clusterMembership[[dName]]
                        subGEPs <- allGEPs[which(allGEPs$Data == dName), , drop = FALSE]

                        for (whichComm in community) {
                                commName <- paste0("Community_", whichComm)
                                commSpecificGEPs <- subGEPs[which(subGEPs$Community == whichComm), , drop = FALSE]
                                if (nrow(commSpecificGEPs) > 0) {
                                        allSamples <- c()
                                        for (gep in commSpecificGEPs$GEP) allSamples <- c(allSamples, cl[[gep]])
                                        idx <- .demo5_getGLASSidx(unique(allSamples), glassAnnot)
                                        noSamples <- sapply(idx$molecularSubtype, length)

                                        if (sum(noSamples) != 0) {
                                                vertexPie[[commName]] <- noSamples
                                                vertexSize[whichComm] <- igraph::V(commNetwork)$size[whichComm]
                                                vertexLabel[whichComm] <- igraph::V(commNetwork)$name[whichComm]
                                        }
                                }
                        }

                        return(list(
                                vertexLabel = vertexLabel,
                                vertexSize  = vertexSize,
                                vertexPie   = vertexPie,
                                legend      = legend,
                                legendCol   = legendCol
                        ))
                }

                # IVYGAP
                if (identical(annot_type, "ivygap")) {
                        dName <- "IVYGAP"
                        if (is.null(clusterMembership[[dName]])) {
                                demo5_last_error("ERROR: IVYGAP is not present in soObj@sample2metagene. Confirm IVYGAP was included in the analysis.")
                                return(NULL)
                        }

                        legend <- c(
                                "Cellular_Tumor",
                                "Infiltrating_Tumor",
                                "Leading_Edge",
                                "Microvascular_proliferation",
                                "Pseudopalisading_cells_around_necrosis"
                        )
                        legendLbl <- names(.demo5_pieColors$IVYGAP)
                        legendCol <- .demo5_pieColors$IVYGAP

                        init <- .init_vertexInfo(legend)
                        vertexLabel <- init$vertexLabel
                        vertexSize <- init$vertexSize
                        vertexPie <- init$vertexPie

                        cl <- clusterMembership[[dName]]
                        subGEPs <- allGEPs[which(allGEPs$Data == dName), , drop = FALSE]

                        for (whichComm in community) {
                                commName <- paste0("Community_", whichComm)
                                commSpecificGEPs <- subGEPs[which(subGEPs$Community == whichComm), , drop = FALSE]
                                if (nrow(commSpecificGEPs) > 0) {
                                        allSamples <- c()
                                        for (gep in commSpecificGEPs$GEP) allSamples <- c(allSamples, cl[[gep]])
                                        idx <- .demo5_getIVYGAPidx(unique(allSamples))
                                        noSamples <- sapply(idx, length)

                                        if (sum(noSamples) != 0) {
                                                vertexPie[[commName]] <- noSamples
                                                vertexSize[whichComm] <- igraph::V(commNetwork)$size[whichComm]
                                                vertexLabel[whichComm] <- igraph::V(commNetwork)$name[whichComm]
                                        }
                                }
                        }

                        return(list(
                                vertexLabel = vertexLabel,
                                vertexSize  = vertexSize,
                                vertexPie   = vertexPie,
                                legend      = legend,
                                legendLbl   = legendLbl,
                                legendCol   = legendCol
                        ))
                }

                # Fallback
                return(NULL)
        })

        output$demo5_comm_network <- renderPlot({
                demo5_last_error(NULL)

                soObj5 <- demo4_soObj()
                req(soObj5)

                vinfo <- demo5_vertexInfo()
                # vinfo can be NULL (layout-only)

                tryCatch(
                        {
                                sotk2::plotCommNetwork(
                                        soObj5,
                                        vertexInfo = vinfo,
                                        filename = NULL
                                )
                        },
                        error = function(e) {
                                demo5_last_error(paste0("ERROR: plotCommNetwork() failed: ", conditionMessage(e)))
                                return(NULL)
                        }
                )
        })
        #### -- End of Step 5.

        # ---- Step 6.
        demo6_last_error <- reactiveVal(NULL)
        .demo6_cache <- reactiveValues(nmf = list())
        .demo6_get_nmf_cached <- function(cohort) {
                if (!is.null(.demo6_cache$nmf[[cohort]])) {
                        return(.demo6_cache$nmf[[cohort]])
                }

                p <- file.path(data_dir, paste0("nmfRes_", cohort, ".RDS"))
                if (!file.exists(p)) {
                        return(NULL)
                }

                obj <- readRDS(p)
                .demo6_cache$nmf[[cohort]] <- obj
                return(obj)
        }

        output$demo6_comm_ui <- renderUI({
                req(identical(input$demos_step, "Step 6"))

                soObj_now <- demo4_soObj()
                req(soObj_now)

                max_comm <- length(soObj_now@commCols)
                if (!is.finite(max_comm) || max_comm < 1) max_comm <- 1

                current <- suppressWarnings(as.integer(input$demo6_comm))
                if (length(current) != 1 || is.na(current) || current < 1) current <- 1
                if (current > max_comm) current <- max_comm

                numericInput(
                        inputId = "demo6_comm",
                        label = "Community",
                        value = current,
                        min = 1,
                        max = max_comm,
                        step = 1
                )
        })

        # Keep demo6_comm within range if upstream community count changes
        observeEvent(demo4_soObj(),
                {
                        if (!identical(input$demos_step, "Step 6")) {
                                return(invisible(NULL))
                        }

                        soObj_now <- demo4_soObj()
                        req(soObj_now)

                        max_comm <- length(soObj_now@commCols)
                        if (!is.finite(max_comm) || max_comm < 1) max_comm <- 1

                        current <- suppressWarnings(as.integer(input$demo6_comm))
                        if (length(current) != 1 || is.na(current) || current < 1) current <- 1
                        if (current > max_comm) current <- max_comm

                        updateNumericInput(session, "demo6_comm", max = max_comm, value = current)
                        return(invisible(NULL))
                },
                ignoreInit = TRUE
        )

        output$demo6_geomean_plot <- renderPlot({
                demo6_last_error(NULL)
                req(identical(input$demos_step, "Step 6"))

                if (!requireNamespace("igraph", quietly = TRUE)) {
                        demo6_last_error("ERROR: igraph is required for Step 6.")
                        return(NULL)
                }
                if (!requireNamespace("stringr", quietly = TRUE)) {
                        demo6_last_error("ERROR: stringr is required for Step 6.")
                        return(NULL)
                }
                if (!requireNamespace("NMF", quietly = TRUE)) {
                        demo6_last_error("ERROR: NMF is required for Step 6.")
                        return(NULL)
                }

                soObj_now <- demo4_soObj()
                req(soObj_now)

                cohort <- input$demo6_cohort
                if (is.null(cohort) || length(cohort) != 1 || !(cohort %in% c("GLASS", "IVYGAP"))) {
                        cohort <- "GLASS"
                }

                comm <- suppressWarnings(as.integer(input$demo6_comm))
                if (length(comm) != 1 || is.na(comm) || comm < 1) {
                        comm <- 1
                }

                nmfObj <- .demo6_get_nmf_cached(cohort)
                if (is.null(nmfObj)) {
                        demo6_last_error(paste0("ERROR: nmfRes_", cohort, ".RDS not found under ./", data_dir, "."))
                        return(NULL)
                }

                # Identify metagenes in the selected community for the selected cohort
                nodes <- igraph::V(soObj_now@corNetwork)
                node_comm <- nodes$community
                names(node_comm) <- nodes$name

                metagenes <- names(node_comm)[which(node_comm == comm)]
                metagenes <- metagenes[which(sapply(stringr::str_split(metagenes, "\\$"), "[[", 1) == cohort)]

                if (length(metagenes) == 0) {
                        graphics::plot.new()
                        graphics::text(0.5, 0.5, paste0("No metagenes in Community #", comm, " for ", cohort, "."), cex = 1)
                        return(invisible(NULL))
                }

                # Build usage matrix: rows = metagenes, columns = samples
                usageMat <- NULL
                for (metagene in metagenes) {
                        buff <- unlist(stringr::str_split(metagene, "\\$"))
                        if (length(buff) < 3) next

                        k <- suppressWarnings(as.numeric(buff[3]))
                        r <- suppressWarnings(as.numeric(buff[2]))
                        if (is.na(k) || is.na(r)) next

                        usage <- NMF::coef(get(as.character(k), nmfObj$fit))

                        rowSum <- apply(usage, 1, sum)
                        nUsage <- usage / rowSum

                        usageMat <- rbind(usageMat, nUsage[r, ])
                }

                if (is.null(usageMat) || nrow(usageMat) == 0) {
                        graphics::plot.new()
                        graphics::text(0.5, 0.5, "Unable to extract usage values for the selected community.", cex = 1)
                        return(invisible(NULL))
                }

                # Geometric mean per sample (avoid zeros)
                usageMat[usageMat == 0] <- 1e-8
                rep <- apply(usageMat, 2, .demo6_geoMean)
                names(rep) <- colnames(usageMat)

                # Plot ECDFs stratified by cohort-specific annotations
                if (identical(cohort, "GLASS")) {
                        annot_path <- file.path(data_dir, "annot_GLASS.RDS")
                        if (!file.exists(annot_path)) {
                                demo6_last_error("ERROR: annot_GLASS.RDS not found under ./data (required for GLASS strata).")
                                return(NULL)
                        }
                        glassAnnot <- readRDS(annot_path)

                        idx <- .demo6_getGLASSidx(names(rep), glassAnnot)

                        priIdx <- idx$sampleType$Pri
                        recIdx <- idx$sampleType$Rec
                        claIdx <- idx$molecularSubtype$Cla
                        mesIdx <- idx$molecularSubtype$Mes
                        proIdx <- idx$molecularSubtype$Pro

                        pri <- rep[priIdx]
                        pri <- pri[order(pri)]
                        priF <- ecdf(rep[priIdx])
                        rec <- rep[recIdx]
                        rec <- rec[order(rec)]
                        recF <- ecdf(rep[recIdx])
                        cla <- rep[claIdx]
                        cla <- cla[order(cla)]
                        claF <- ecdf(rep[claIdx])
                        mes <- rep[mesIdx]
                        mes <- mes[order(mes)]
                        mesF <- ecdf(rep[mesIdx])
                        pro <- rep[proIdx]
                        pro <- pro[order(pro)]
                        proF <- ecdf(rep[proIdx])

                        graphics::plot(
                                pri, priF(pri),
                                col = .demo6_colors$GLASS$sampleType["Primary"],
                                xlab = "GeoMean(GEP usage)",
                                ylab = "ECDF",
                                main = paste0("GLASS, Community #", comm),
                                type = "l",
                                lwd = 3,
                                xlim = c(0, max(rep)),
                                ylim = c(0, 1)
                        )
                        graphics::lines(rec, recF(rec), col = .demo6_colors$GLASS$sampleType["Recurrence"], lwd = 3)
                        graphics::lines(cla, claF(cla), col = .demo6_colors$GLASS$molecularSubtype["Classical"], lwd = 3, lty = 2)
                        graphics::lines(mes, mesF(mes), col = .demo6_colors$GLASS$molecularSubtype["Mesenchymal"], lwd = 3, lty = 2)
                        graphics::lines(pro, proF(pro), col = .demo6_colors$GLASS$molecularSubtype["Proneural"], lwd = 3, lty = 2)

                        graphics::legend(
                                "bottomright",
                                legend = c(
                                        paste0("Primary (", length(priIdx), ")"),
                                        paste0("Recurrence (", length(recIdx), ")"),
                                        NA,
                                        paste0("Classical (", length(claIdx), ")"),
                                        paste0("Mesenchymal (", length(mesIdx), ")"),
                                        paste0("Proneural (", length(proIdx), ")")
                                ),
                                col = c(
                                        .demo6_colors$GLASS$sampleType["Primary"],
                                        .demo6_colors$GLASS$sampleType["Recurrence"],
                                        NA,
                                        .demo6_colors$GLASS$molecularSubtype["Classical"],
                                        .demo6_colors$GLASS$molecularSubtype["Mesenchymal"],
                                        .demo6_colors$GLASS$molecularSubtype["Proneural"]
                                ),
                                pch = 15,
                                pt.cex = 2.8,
                                bty = "n",
                                ncol = 2
                        )
                } else {
                        idx <- .demo6_getIVYGAPidx(names(rep))

                        ctIdx <- idx$CT
                        itIdx <- idx$IT
                        leIdx <- idx$LE
                        mvpIdx <- idx$MVP
                        panIdx <- idx$PAN

                        ct <- rep[ctIdx]
                        ct <- ct[order(ct)]
                        ctF <- ecdf(rep[ctIdx])
                        it <- rep[itIdx]
                        it <- it[order(it)]
                        itF <- ecdf(rep[itIdx])
                        le <- rep[leIdx]
                        le <- le[order(le)]
                        leF <- ecdf(rep[leIdx])
                        mvp <- rep[mvpIdx]
                        mvp <- mvp[order(mvp)]
                        mvpF <- ecdf(rep[mvpIdx])
                        pan <- rep[panIdx]
                        pan <- pan[order(pan)]
                        panF <- ecdf(rep[panIdx])

                        graphics::plot(
                                ct, ctF(ct),
                                col = .demo6_colors$IVYGAP["CT"],
                                xlab = "GeoMean(GEP usage)",
                                ylab = "ECDF",
                                main = paste0("IVYGAP, Community #", comm),
                                type = "l",
                                lwd = 3,
                                xlim = c(0, max(rep)),
                                ylim = c(0, 1)
                        )
                        graphics::lines(it, itF(it), col = .demo6_colors$IVYGAP["IT"], lwd = 3)
                        graphics::lines(le, leF(le), col = .demo6_colors$IVYGAP["LE"], lwd = 3)
                        graphics::lines(mvp, mvpF(mvp), col = .demo6_colors$IVYGAP["MVP"], lwd = 3)
                        graphics::lines(pan, panF(pan), col = .demo6_colors$IVYGAP["PAN"], lwd = 3)

                        graphics::legend(
                                "bottomright",
                                legend = c(
                                        paste0("CT (", length(ctIdx), ")"),
                                        paste0("IT (", length(itIdx), ")"),
                                        paste0("LE (", length(leIdx), ")"),
                                        paste0("MVP (", length(mvpIdx), ")"),
                                        paste0("PAN (", length(panIdx), ")")
                                ),
                                col = c(
                                        .demo6_colors$IVYGAP["CT"],
                                        .demo6_colors$IVYGAP["IT"],
                                        .demo6_colors$IVYGAP["LE"],
                                        .demo6_colors$IVYGAP["MVP"],
                                        .demo6_colors$IVYGAP["PAN"]
                                ),
                                pch = 15,
                                pt.cex = 2.8,
                                bty = "n",
                                ncol = 1
                        )
                }

                return(invisible(NULL))
        })

        output$demo6_download_soObj <- downloadHandler(
                filename = function() {
                        paste0("soObj_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RDS")
                },
                content = function(file) {
                        soObj_now <- demo4_soObj()
                        req(soObj_now)
                        saveRDS(soObj_now, file = file)
                }
        )
        #### -- End of Step 6.

        ## End of scripts
}

#### #### #### #### #### #### #### #### #### ####
# Allez-y!
shinyApp(ui = ui, server = server)
# (@'3(o.o);
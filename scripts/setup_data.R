#### #### #### #### #### #### #### #### #### ####
# setup_data.R
#
# One-shot setup for the sotk2-shiny demo data.
#
# Steps:
#   1. Fetch the core demo files (nmfRes_*.RDS + annot_GLASS.RDS + expr_GLASS.RDS)
#      from Zenodo via sotk2::download_demo_data().
#   2. Build the precomputed soObj.RDS using the default settings expected by
#      the Shiny app (matching Rsource/preset.R).
#
# Run once from the repo root:
#   Rscript scripts/setup_data.R
#### #### #### #### #### #### #### #### #### ####

if (!requireNamespace("sotk2", quietly = TRUE)) {
        stop(
                "Package 'sotk2' (>= 1.0.0) is required. Install with:\n",
                "  install.packages('devtools')\n",
                "  devtools::install_github('Snyder-Institute/sotk2')"
        )
}

repo_root <- normalizePath(file.path(dirname(sys.frame(1)$ofile), ".."), mustWork = TRUE)
data_dir <- file.path(repo_root, "data")
if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

message("[1/2] Downloading core demo data into ", data_dir, " ...")
sotk2::download_demo_data(set = "core", download_dir = data_dir)

soObj_path <- file.path(data_dir, "soObj.RDS")
if (file.exists(soObj_path)) {
        message("[2/2] soObj.RDS already present; skipping rebuild. ",
                "Delete it manually if you want to regenerate.")
} else {
        message("[2/2] Building soObj.RDS with default settings ",
                "(seed=1234, niter=1000, coefThre=0.3, commWeight=100, cohortWeight=10) ...")

        nmfObjL <- list(
                GLASS   = readRDS(file.path(data_dir, "nmfRes_GLASS.RDS")),
                IVYGAP  = readRDS(file.path(data_dir, "nmfRes_IVYGAP.RDS")),
                HEILAND = readRDS(file.path(data_dir, "nmfRes_HEILAND.RDS"))
        )

        rankL <- list(
                GLASS   = c(3:10, 15, 20),
                IVYGAP  = c(3:10, 15, 20),
                HEILAND = seq(5, 30, 5)
        )

        dataCol <- c("GLASS" = "cyan3", "IVYGAP" = "chartreuse1", "HEILAND" = "magenta")

        soSet <- sotk2::SOSet(
                NMFobjL  = nmfObjL,
                NMFrankL = rankL,
                dataCol  = dataCol,
                corMet   = "spearman"
        )

        soObj <- sotk2::SOTK(
                SOSet        = soSet,
                coefThre     = 0.3,
                seed         = 1234,
                niter        = 1000,
                commWeight   = 100,
                cohortWeight = 10,
                searchMet    = "greedy"
        )

        saveRDS(soObj, soObj_path)
        message("Wrote ", soObj_path)
}

message("Done. Data directory contents:")
print(list.files(data_dir))

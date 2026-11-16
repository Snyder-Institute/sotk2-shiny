<!--
overview.md
Purpose: landing/overview page for the sotk2 Shiny app (Markdown file with embedded CSS/HTML).
Notes:
- Avoid Markdown tables for layout (many renderers escape block-level HTML inside table cells).
- Use a simple CSS grid so two cards align side-by-side responsively.
-->

<style>
/* Page container (optional): wrap your includeMarkdown output with a div.page-content if you want to constrain width. */
.page-content {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 12px;
}

/* Typography */
h2, h3 { margin-top: 18px; }
p { line-height: 1.55; }
.muted { color: #666666; font-size: 12px; }

/* Two-card grid */
.grid-2{
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  align-items: stretch;   /* ensures items stretch to row height */
}

/* Make each card fill the grid cell height */
.grid-2 .card{
  height: 100%;
  display: flex;          /* enable vertical layout */
  flex-direction: column; /* stack children vertically */
}

/* If you want the callout to stay at the bottom of the card */
.grid-2 .card .callout{
  margin-top: auto;
}

.card {
  border: 1px solid #e6e6e6;
  border-radius: 12px;
  padding: 14px 16px;
  background: #ffffff;
}

.card h3 {
  margin: 0 0 10px 0;
}

.callout {
  margin-top: 10px;
  padding: 10px 12px;
  border-left: 4px solid #404f7c; /* dark blue */
  background: #f7f9ff;
  border-radius: 8px;
}

.hr-soft {
  border: 0;
  border-top: 1px solid #efefef;
  margin: 16px 0;
}
</style>

<center><img src="./imgs/logo.png" width="450"></center>

## About sotk2

**sotk2** is an R package for integrating omics datasets **using modules derived from non-negative matrix factorization (NMF) or consensus NMF (cNMF)**. The core idea is to treat each gene expression program (metagene) as a comparable unit across datasets, then integrate programs through a **correlation-based network** followed by **community detection**.

**sotk2** is designed to be **self-contained and independent**: it does not require any prior packages or objects outside this repository. Inputs may come from any platform or modality (for example, bulk RNA-seq, single-cell RNA-seq, spatial transcriptomics, or protein abundance), as long as NMF/cNMF outputs are available (or can be imported).

<div class="hr-soft"></div>

<div class="grid-2">
  <div class="card">
    <h3><i>Materials</i></h3>
    <p style="margin:0 0 10px 0;">
      This demo uses three cohorts from the <strong>sotk2</strong> tutorial:
    </p>
    <ul style="margin:0;">
      <li><strong>GLASS</strong> (Glioma Longitudinal AnalySiS Consortium; <a href="https://www.synapse.org/glass" target="_blank">PMID: 29432615</a>): bulk RNA-seq from matched primary and recurrent glioma samples</li>
      <li><strong>IVYGAP</strong> (Ivy Glioblastoma Atlas Project; <a href="https://glioblastoma.alleninstitute.org/" target="_blank">29748285</a>): bulk RNA-seq stratified by anatomic features (CT, IT, LE, MVP, PAN)</li>
      <li><strong>HEILAND</strong> (Ravi et al., Cancer Cell, 2022; <a href="https://doi.org/10.5061/dryad.h70rxwdmj" target="_blank">35700707</a>): 10x Genomics Visium v1 spatial transcriptomics</li>
    </ul>    
    <div class="callout">
      <div class="muted">
        Reprocessed data used in this tutorial are deposited on <a href="https://doi.org/10.5281/zenodo.18063318" target="_blank">Zenodo</a>.
      </div>
    </div>
  </div>

  <div class="card">
    <h3><i>Methods</i></h3>
    <p style="margin:0 0 10px 0;">At a high level, <strong>sotk2</strong>:</p>
    <ol style="margin:0;" type="i">
      <li>Collects metagenes from multiple NMF runs</li>
      <li>Computes cross-metagene correlation structure</li>
      <li>Constructs a metagene correlation network</li>
      <li>Detects biological modules (communities)</li>
      <li>Abstract and construct a community-level network</li>
      <li>Summarizes communities via cohort-aware annotation and usage-based diagnostics</li>
    </ol>
    <div class="callout">
      <div class="muted">
        <i>Metagene</i> and <i>GEP</i> are used interchangeably to match NMF/cNMF terminology.
      </div>
    </div>
  </div>
</div>

<div class="hr-soft"></div>

## Conceptual schematic
<center>
  <img src="./imgs/schematic.png" alt="Conceptual schematic" style="max-width: 900px; width: 100%; border: 1px dashed #cccccc; border-radius: 10px; padding: 10px;">
</center>

<div class="hr-soft"></div>

## Features

  * Identification of biologically meaningful latent factors from deconvoluted omics data
  * Data-driven rank selection across multiple NMF or cNMF runs
  * Correlation-based integration of biological modules across datasets and platforms
  * Support for spatial, bulk, single-cell, and protein-level omics data
  * Community abstraction and network-level visualization for large integrative analyses
  * Assessing sample-type enrichment using Pearson residuals (observed vs expected counts; Chi-squared framework)
  * Consistent network layouts for comparative, cross-dataset interpretation

<div class="hr-soft"></div>

<div class="grid-2">
  <div class="card">
    <h3>GitHub and Documentation</h3>
    <p style="margin:0 0 8px 0;">
      Source code: <a href="https://github.com/Snyder-Institute/sotk2" target="_blank" rel="noopener noreferrer">github.com/Snyder-Institute/sotk2</a>
    </p>
    <p style="margin:0;">
      Documentation: <a href="https://Snyder-Institute.github.io/sotk2/" target="_blank" rel="noopener noreferrer">Snyder-Institute.github.io/sotk2</a>
    </p>    
  </div>

  <div class="card">
    <h3>Citation</h3>
    <p style="margin:0 0 10px 0;">
      <a href="https://doi.org/10.64898/2026.05.20.726700" target="_blank" rel="noopener noreferrer">Reproducible transcriptional modules define glioblastoma ecosystems across independent cohorts</a>.
    </p>    
  </div>
</div>
<br />

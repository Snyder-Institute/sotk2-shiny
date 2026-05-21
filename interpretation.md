<style>
/* -----------------------------
   Global readability defaults
------------------------------ */
.interp-wrap {
  max-width: 1100px;
  margin: 0 auto;
  line-height: 1.55;
  color: #222;
}
.interp-wrap h1, .interp-wrap h2, .interp-wrap h3 {
  margin: 0.9em 0 0.4em 0;
}
.interp-wrap p {
  margin: 0.5em 0;
}
.interp-muted {
  color: #4d4d4d;
  font-size: 0.95em;
}

/* -----------------------------
   Step cards + tables
------------------------------ */
.step-card {
  border: 1px solid #e6e6e6;
  border-radius: 12px;
  padding: 14px 16px;
  margin: 14px 0 18px 0;
  background: #fff;
}
.step-title {
  font-size: 1.15em;
  font-weight: 700;
  margin-bottom: 4px;
}
.step-subtitle {
  margin: 0 0 10px 0;
  color: #4d4d4d;
}

.step-table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  margin-top: 10px;
}
.step-table td {
  border: 1px solid #ededed;
  vertical-align: top;
  padding: 12px 12px 10px 12px;
}
.step-table .cell-head {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 0.86em;
  font-weight: 700;
  margin-bottom: 8px;
}

.cell-rep  { background: rgba(133, 218, 250, 0.35); color: #1a3c55; }
.cell-look { background: rgba( 64,  79, 124, 0.12); color: #2a2f4f; }
.cell-use  { background: rgba( 16, 185, 129, 0.16); color: #065f46; }
.cell-note { background: rgba(214, 104,  83, 0.14); color: #5a1f16; }

.step-snapshot {
  display: flex;
  gap: 14px;
  align-items: center;
}
.step-snapshot .snap-box {
  flex: 1;
  border: 1px dashed #cfcfcf;
  border-radius: 12px;
  padding: 14px;
  background: #fafafa;
}
.step-snapshot .snap-title {
  font-weight: 700;
  margin-bottom: 6px;
}
.step-snapshot img {
  max-width: 100%;
  height: auto;
  display: block;
  border-radius: 10px;
}

.code-inline {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  font-size: 0.95em;
  background: #f6f6f6;
  padding: 1px 6px;
  border-radius: 6px;
}
.ul-tight       { margin: 6px 0 0 18px; }
.ul-tight li    { margin: 4px 0; }
</style>

<div class="interp-wrap">

# How to read each tutorial step

This page explains what each tutorial figure is showing and how to interpret it.  

<div class="step-card">

<div class="step-title">Step 1: Examine correlation structure</div>
<table class="step-table">
  <tr>
    <td>
      <div class="cell-head cell-rep">What this figure represents</div>
      <p>
        A grid of histograms summarizing pairwise correlations among GEPs (metagenes).
        Diagonal panels show within-cohort correlations, and off-diagonal panels show between-cohort correlations.
      </p>
    </td>
    <td>
      <div class="cell-head cell-look">What to look for</div>
      <ul class="ul-tight">
        <li>Broad vs. narrow distributions: broad tails suggest stronger shared structure or batch effects.</li>
        <li>Between-cohort shifts: large differences vs. within-cohort panels can indicate cohort-specific signals.</li>
        <li>Heavy positive tail: implies many metagene pairs move together (may tighten the network at moderate thresholds).</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div class="step-snapshot">
        <div class="snap-box">
          <div class="snap-title">Correlation coefficient density plots across and within cohorts</div>
          <img src="imgs/01_Stats_correlation_density.png" alt="Step 1">
        </div>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div class="cell-head cell-use">How to use it</div>
      <ul class="ul-tight">
        <li>Use as a sanity check before network construction: verify distributions look plausible and not degenerate.</li>
        <li>Use the positive tail to choose a reasonable correlation threshold for Step 2.</li>
        <li><b>Compare cohorts to anticipate which cohort combinations will form dense cross-links.</b></li>
      </ul>
    </td>
    <td>
      <div class="cell-head cell-note">Note</div>
      <ul class="ul-tight">
        <li>Adjust the rank grid to keep the total number of GEPs broadly comparable across cohorts, so the correlation network is not dominated by one cohort simply due to having more metagenes (which can inflate cross-links and community size).</li>
        <li>In this tutorial, rank grids are fixed to match the precomputed cNMF objects distributed with the demo data.</li>
      </ul>
    </td>
  </tr>
</table>

</div>

<div class="step-card">

<div class="step-title">Step 2: Construct the correlation network</div>
<table class="step-table">
  <tr>
    <td>
      <div class="cell-head cell-rep">What this figure represents</div>
      <p>
        A graph where nodes are GEPs (metagenes) and edges connect metagene pairs whose correlation exceeds the chosen threshold.
        This step uses an unweighted network (<span class="code-inline">weighted = FALSE</span>) and annotates nodes by cohort.
      </p>
    </td>
    <td>
      <div class="cell-head cell-look">What to look for</div>
      <ul class="ul-tight">
        <li>Connectivity: an overly dense graph suggests the threshold is too permissive; a fragmented graph suggests it is too strict.</li>
        <li>Cohort mixing: strong cross-cohort connectivity indicates reproducible programs across cohorts.</li>
        <li>Isolated components: may reflect cohort-specific programs or low-quality fits.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div class="step-snapshot">
        <div class="snap-box">
          <div class="snap-title">Unweighted correlation network after applying the coefficient threshold</div>
          <img src="./imgs/02_Network_Unweighted.png" alt="Step 2">
        </div>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div class="cell-head cell-use">How to use it</div>
      <ul class="ul-tight">
        <li><b>Adjust the correlation threshold to obtain a network that is connected enough for community detection but not dominated by noise.</b></li>
        <li>Optionally toggle labels to inspect specific metagenes when validating data integration.</li>
      </ul>
    </td>
    <td>
      <div class="cell-head cell-note">Note</div>
      <ul class="ul-tight">
        <li>Adjust the rank grid and the correlation coefficient threshold so the resulting network contains a broadly comparable number of GEPs from each cohort, enabling more balanced integrative comparisons.</li>
        <li>At this stage, edge weights are not used for layout. The primary goal is to define which relationships are retained for downstream community detection.</li>
      </ul>
    </td>
  </tr>
</table>

</div>

<div class="step-card">

<div class="step-title">Step 3: Detect communities</div>
<table class="step-table">
  <tr>
    <td>
      <div class="cell-head cell-rep">What this figure represents</div>
      <p>
        The same unweighted correlation network as Step 2, with nodes annotated by community assignment
        (<span class="code-inline">annot = 'community'</span>). Communities are identified using the selected method
        (<span class="code-inline">searchMet</span>).
      </p>
    </td>
    <td>
      <div class="cell-head cell-look">What to look for</div>
      <ul class="ul-tight">
        <li>Stable, well-separated modules: visually distinct clusters indicate coherent programs.</li>
        <li>Over-fragmentation: too many tiny communities can suggest a strict threshold or noisy correlations.</li>
        <li>Over-merging: one dominant community can indicate an overly dense network.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div class="step-snapshot">
        <div class="snap-box">
          <div class="snap-title">Community detection on the correlation network using a selectable algorithm</div>
          <img src="./imgs/04_Network_Unweighted_Comm.png" alt="Step 3">
        </div>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div class="cell-head cell-use">How to use it</div>
      <ul class="ul-tight">
        <li><b>Compare community detection algorithms to assess robustness of module boundaries.</b></li>
        <li>Tune Step 2 threshold first; then choose an algorithm that yields interpretable module structure.</li>
        <li>Use node size, label size, and edge alpha to improve readability (visualization only).</li>
      </ul>
    </td>
    <td>
      <div class="cell-head cell-note">Note</div>
      <ul class="ul-tight">
        <li>No single community detection algorithm is universally optimal. Try multiple algorithms and evaluate how GEPs cluster into communities using the Step 4 visualization. Prefer an approach that yields both (i) shared communities that plausibly represent cross-cohort biological modules and (ii) cohort-specific modules that reflect dataset-specific signal, limitations, or technical/biological specificity.</li>
      </ul>
    </td>
  </tr>
</table>

</div>

<div class="step-card">

<div class="step-title">Step 4: Refine network layout for interpretation</div>
<table class="step-table">
  <tr>
    <td>
      <div class="cell-head cell-rep">What this figure represents</div>
      <p>
        A weighted layout view (<span class="code-inline">weighted = TRUE</span>) of the metagene network.
Compare the two panels by toggling the annotation (<span class="code-inline">annot = ‘community’</span> vs <span class="code-inline">annot = ‘cohort’</span>) to assess mixing at different levels: the left highlights module structure (communities), while the right shows whether modules are shared across cohorts or dominated by a single cohort.
      </p>
    </td>
    <td>
      <div class="cell-head cell-look">What to look for</div>
      <ul class="ul-tight">
        <li>Community cohesion: communities should remain visually compact under weighted layout.</li>
        <li>Cohort overlays: identify cohort-driven segregation vs. shared modules.</li>
        <li>Ambiguous boundary nodes: nodes bridging communities may represent shared biology or technical overlap.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div class="step-snapshot">
        <div class="snap-box">
          <div class="snap-title">Weighted layout view to emphasize stronger relationships and improve readability</div>
          <img src="./imgs/06_Network_Community.png" alt="Step 4">
        </div>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div class="cell-head cell-use">How to use it</div>
      <ul class="ul-tight">
        <li>Use this view to produce a clean, presentation-ready layout after selecting a community method (Step 3).</li>
        <li>Switch annotation (community vs cohort) to assess whether modules are shared across cohorts or cohort-driven.</li>
        <li><b>Adjust rewiring weights to reduce overlap and edge crossings for readability</b>; they refine layout only and do not change community detection.</li>
      </ul>
    </td>
    <td>
      <div class="cell-head cell-note">Note</div>
      <ul class="ul-tight">
        <li>Users generally aim to identify communities that are shared across cohorts, as these are more likely to reflect robust biological modules. Be cautious with communities that are isolated or dominated by a single cohort, as they may reflect cohort-specific artifacts or technical effects.</li>
        <li>Rewiring weights are intended to improve layout interpretability and do not replace selecting an appropriate correlation threshold or community detection algorithm.</li>
      </ul>
    </td>
  </tr>
</table>

</div>

<div class="step-card">

<div class="step-title">Step 5: Summarize communities at the module level</div>
<table class="step-table">
  <tr>
    <td>
      <div class="cell-head cell-rep">What this figure represents</div>
      <p>
        A community-level network where each node represents a community (module) and edges summarize connectivity between communities. The four panels show the same community graph with different overlays: layout-only (top-left), GLASS primary vs. recurrence (top-right), GLASS molecular subtype (bottom-left), and IVYGAP anatomical features (bottom-right). When annotation is enabled, each node is overlaid with a pie chart summarizing category enrichment/depletion within that community (via standardized chi-squared residuals).
      </p>      
    </td>
    <td>
      <div class="cell-head cell-look">What to look for</div>
      <ul class="ul-tight">
        <li>Pie patterns: enrichment or depletion of metadata categories can suggest phenotype-associated communities.</li>
        <li>Dominant communities: large nodes may represent broad programs or merged biology.</li>
        <li>Strong inter-community links: thick edges suggest shared signals or transitional modules.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div class="step-snapshot">
        <div class="snap-box">
          <div class="snap-title">Community-level network with optional cohort-specific pie annotations</div>
          <img src="./imgs/11_community_network_layout.png" alt="Step 5">
        </div>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div class="cell-head cell-use">How to use it</div>
      <ul class="ul-tight">
        <li><b>Use as a summary figure to prioritize communities for downstream biological interpretation.</b></li>
        <li>Use pies to evaluate whether specific communities are associated with sample annotations (e.g., subtype, recurrence, anatomical region).</li>
        <li>Cross-check communities that show strong, cohort-specific annotation signals against Step 6 (usage ECDFs) to confirm that the pattern reflects consistent activity differences rather than a small subset of metagenes.</li>
      </ul>
    </td>
    <td>
      <div class="cell-head cell-note">Note</div>
      <ul class="ul-tight">
        <li>If a cohort lacks curated sample annotations, you can use communities that are well-annotated in other cohorts as a reference and infer plausible sample- or community-level labels by mapping the unannotated cohort’s metagenes to those reference communities (i.e., transferring annotation via shared community membership rather than direct metadata).</li>
        <li>Positive residuals indicate over-representation relative to expectation; negative residuals indicate under-representation.</li>
      </il>
    </td>
  </tr>
</table>

</div>

<div class="step-card">

<div class="step-title">Step 6: Community-level GEP usage (geometric mean)</div>
<table class="step-table">
  <tr>
    <td>
      <div class="cell-head cell-rep">What this figure represents</div>
      <p>
        For the selected cohort and community, metagene usage is summarized per sample by taking the geometric mean across all metagenes assigned to that community (within the selected cohort). ECDF curves then show how community activity is distributed across samples and across available strata (e.g., primary vs. recurrence; molecular subtype; anatomical region). In the example shown, the left and right panels correspond to Community #1 and Community #6, respectively, and both were annotated as primary-enriched communities based on the GLASS sample-type annotation in Step 5.
      </p>
    </td>
    <td>
      <div class="cell-head cell-look">What to look for</div>
      <ul class="ul-tight">
        <li>Curve separation: large shifts between strata indicate annotation-associated community activity.</li>
        <li>Heavy right tail: a subset of samples with unusually high activity in this community.</li>
        <li>Overlap: suggests activity is broadly shared across strata.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <div class="step-snapshot">
        <div class="snap-box">
          <div class="snap-title">Per-sample community activity summarized from metagene usage and stratified by metadata</div>
          <img src="./imgs/15_GLASS_GEP_usage_geomean_community.png" alt="Step 6">
        </div>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div class="cell-head cell-use">How to use it</div>
      <ul class="ul-tight">
        <li><b>Use this view to identify communities whose activity distribution is shifted between strata</b> (e.g., primary vs. recurrence), even when the community-level annotation in Step 5 appears similar.</li>
	      <li>Use alongside Step 5 to distinguish “annotation-enriched” communities from communities that are actually activity-shifted within that annotation group.</li>
        <li>Use Step 5 and Step 6 together: Step 5 summarizes who is assigned to a community (membership/annotation enrichment), while Step 6 quantifies how strongly that community is expressed (continuous activity); they are complementary for interpretation.</li>
      </ul>
    </td>
    <td>
      <div class="cell-head cell-note">Note</div>
      <ul class="ul-tight">
        <li>Communities annotated as the same category in Step 5 can still show opposite activity shifts in Step 6.</li>
	      <li>This can occur because Step 5 annotations are driven by membership counts under the maximum-usage assignment rule (each sample contributes to the GEP where its usage is maximal), whereas Step 6 reflects continuous usage magnitudes aggregated across metagenes.</li>
	      <li>In sparse or heterogeneous samples, a community may be labeled “primary-enriched” by membership but exhibit higher geometric-mean activity in recurrence (or vice versa), revealing competition or mixing between strata that the max-assignment heuristic can obscure.</li>
      </ul>
    </td>
  </tr>
</table>

</div>

</div>

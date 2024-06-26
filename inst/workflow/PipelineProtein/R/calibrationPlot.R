

#' @title Performs a calibration plot on an `SummarizedExperiment` object,
#' calling the \code{cp4p} package functions.
#' 
#' @description 
#' This function is a wrapper to the calibration.plot method of the
#' \code{cp4p} package for use with `SummarizedExperiment` objects.
#'
#' @param vPVal A dataframe that contains quantitative data.
#'
#' @param pi0Method A vector of the conditions (one condition per sample).
#'
#' @return A plot
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' data(Exp1_R25_prot, package = "DaparToolshedData")
#' obj <- Exp1_R25_prot
#' # Simulate imputation of missing values
#' obj <- NAIsZero(obj, 1)
#' obj <- NAIsZero(obj, 2)
#'  <- as.matrix(assay(obj[[2]]))
#' sTab <- MultiAssayExperiment::colData(obj)
#' limma <- limmaCompleteTest(qData, sTab)
#' wrapperCalibrationPlot(limma$P_Value[, 1])
#'
#' @export
#' 
#' @importFrom cp4p calibration.plot
#'
wrapperCalibrationPlot <- function(vPVal, pi0Method = "pounds") {
  if (is.null(vPVal)) {
    return(NULL)
  }
  requireNamespace('cp4p')
  
  p <- cp4p::calibration.plot(vPVal, pi0.method = pi0Method)
  
  return(p)
}




#' @title Plots a histogram ov p-values
#'
#' @param pval_ll xxx
#'
#' @param bins xxx
#'
#' @param pi0 xxx
#'
#' @return A plot
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' data(Exp1_R25_prot, package = "DaparToolshedData")
#' obj <- Exp1_R25_prot
#' # Simulate imputation of missing values
#' obj <- NAIsZero(obj, 1)
#' obj <- NAIsZero(obj, 2)
#'  <- as.matrix(assay(obj[[2]]))
#' sTab <- MultiAssayExperiment::colData(obj)
#' limma <- limmaCompleteTest(qData, sTab)
#' histPValue_HC(limma$P_Value[1])
#'
#' @export
#' @import highcharter
#' @import graphics
#'
histPValue_HC <- function(pval_ll, bins = 80, pi0 = 1) {

  h <- graphics::hist(sort(unlist(pval_ll)), freq = FALSE, breaks = bins)
  
  # serieInf <- sapply(h$density, function(x) min(pi0, x))
  # serieSup <- sapply(h$density, function(x) max(0, x - pi0))
  
  serieInf <- vapply(h$density, function(x) min(pi0, x), numeric(1))
  serieSup <- vapply(h$density, function(x) max(0, x - pi0), numeric(1))
  
  hc <- highchart() %>%
    hc_chart(type = "column") %>%
    hc_add_series(data = serieSup, name = "p-value density") %>%
    hc_add_series(data = serieInf, name = "p-value density") %>%
    hc_title(text = "P-value histogram") %>%
    hc_legend(enabled = FALSE) %>%
    hc_colors(c("green", "red")) %>%
    hc_xAxis(title = list(text = "P-value"), categories = h$breaks) %>%
    hc_yAxis(
      title = list(text = "Density"),
      plotLines = list(
        list(
          color = "blue", 
          width = 2, 
          value = pi0, 
          zIndex = 5)
      )
    ) %>%
    hc_tooltip(
      headerFormat = "",
      pointFormat = "<b> {series.name} </b>: {point.y} ",
      valueDecimals = 2
    ) %>%
    my_hc_ExportMenu(filename = "histPVal") %>%
    hc_plotOptions(
      column = list(
        groupPadding = 0,
        pointPadding = 0,
        borderWidth = 0
      ),
      series = list(
        stacking = "normal",
        animation = list(duration = 100),
        connectNulls = TRUE,
        marker = list(enabled = FALSE)
      )
    ) %>%
    hc_add_annotation(
      labelOptions = list(
        backgroundColor = "transparent",
        verticalAlign = "top",
        y = -30,
        borderWidth = 0,
        x = 20,
        style = list(
          fontSize = "1.5em",
          color = "blue"
        )
      ),
      labels = list(
        list(
          point = list(
            xAxis = 0,
            yAxis = 0,
            x = 80,
            y = pi0
          ),
          text = paste0("pi0=", pi0)
        )
      )
    )
  return(hc)
}







#' @title Computes the FDR corresponding to the p-values of the
#' differential analysis using
#' 
#' @description 
#' This function is a wrapper to the function adjust.p from the `cp4p` package.
#'  It returns the FDR corresponding to the p-values of the differential 
#' analysis. The FDR is computed with the function \code{p.adjust}\{stats\}.
#'
#' @param adj.pvals xxxx
#'
#' @return The computed FDR value (floating number)
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' NULL
#'
#' @export
#'
diffAnaComputeFDR <- function(adj.pvals) {
  BH.fdr <- max(adj.pvals)
  return(BH.fdr)
}




#' @title Computes the adjusted p-values
#' 
#' @description 
#' This function is a wrapper to the function adjust.p from the `cp4p` package.
#'  It returns the FDR corresponding to the p-values of the differential 
#' analysis. The FDR is computed with the function \code{p.adjust}\{stats\}.
#'
#' @param pval The result (p-values) of the differential analysis processed
#' by \code{\link{limmaCompleteTest}}
#'
#' @param pi0Method The parameter pi0.method of the method adjust.p in the 
#' package \code{cp4p}
#'
#' @return The computed adjusted p-values
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' data(Exp1_R25_prot, package = "DaparToolshedData")
#' obj <- Exp1_R25_prot
#' # Simulate imputation of missing values
#' obj <- NAIsZero(obj, 1)
#' obj <- NAIsZero(obj, 2)
#'  <- as.matrix(assay(obj[[2]]))
#' sTab <- MultiAssayExperiment::colData(obj)
#' limma <- limmaCompleteTest(qData, sTab)
#' df <- data.frame(id = rownames(limma$logFC), logFC = limma$logFC[, 1], pval = limma$P_Value[, 1])
#' 
#' diffAnaComputeAdjustedPValues(pval = limma$P_Value[, 1])
#'
#' @export
#' 
#' @importFrom cp4p adjust.p
#'
diffAnaComputeAdjustedPValues <- function(pval, 
  pi0Method = 1) {
  requireNamespace('cp4p')
  
  padj <- cp4p::adjust.p(pval, pi0Method)
  return(padj$adjp[, 2])
}



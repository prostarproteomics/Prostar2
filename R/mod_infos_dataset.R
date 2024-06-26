#' @title   infos_dataset_ui and infos_dataset_server
#' @description  A shiny Module.
#' 
#' @param id shiny id
#' @param obj An instance of the class `QFeatures`.
#' 
#' @return A shiny app
#'
#' 
#' @name infos_dataset
#' 
#' @examplesIf interactive()
#' data(Exp1_R25_prot, package = 'DaparToolshedData')
#' shiny::runApp(infos_dataset(Exp1_R25_prot))

NULL



#'
#'
#' @rdname infos_dataset
#'
#' @export 
#' @importFrom shiny NS tagList 
#' @import QFeatures
#' @importFrom MagellanNTK format_DT_ui format_DT_server
#' 
infos_dataset_ui <- function(id){
  ns <- NS(id)
  
  tagList(
    uiOutput(ns('title')),
    
    fluidRow(
      column(width=6,
             MagellanNTK::format_DT_ui(ns('dt')),
             br(),
             uiOutput(ns('samples_tab_ui'))
      ),
       column(width=6,
              uiOutput(ns('choose_SE_ui')),
              uiOutput(ns('show_SE_ui'))
       )
    )
  )
}





# Module Server

#' @rdname infos_dataset
#' @export
#' 
#' @keywords internal
#' 
#' @importFrom tibble as_tibble
#' 
infos_dataset_server <- function(id,
  obj = reactive({NULL}),
  remoteReset = reactive({NULL}),
  is.enabled = reactive({TRUE})
  ){
  
  
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    
    rv.infos <- reactiveValues(
      obj = NULL
    )
    
    observeEvent(req(inherits(obj(),'QFeatures')), {
       rv.infos$obj <- obj()
    })
      
      
      
      
      
      
      
      output$samples_tab_ui <- renderUI({
        req(rv.infos$obj)
        
        
        MagellanNTK::format_DT_server('samples_tab',
          obj = reactive({
            req((rv.infos$obj))
            data.frame(colData(rv.infos$obj))
          }),
          hc_style = reactive({
            list(
              cols = colnames(colData(rv.infos$obj)),
              vals = colnames(colData(rv.infos$obj))[2],
              unique = unique(colData(rv.infos$obj)$Condition),
              pal = RColorBrewer::brewer.pal(3,'Dark2')[1:2])
          })
        )
        
        tagList(
          h4("Samples"),
          MagellanNTK::format_DT_ui(ns('samples_tab'))
        )
        
      })
      
      



MagellanNTK::format_DT_server('dt',
      obj = reactive({
        req(Get_QFeatures_summary())
        tibble::as_tibble(Get_QFeatures_summary())
        }))






    output$title <- renderUI({
      req(rv.infos$obj)
      name <- metadata(rv.infos$obj)$analysis
      tagList(
          h3("Dataset summary"),
        p(paste0("Name of analysis:", name$analysis))
        )
    })



    output$choose_SE_ui <- renderUI({
      req(rv.infos$obj)
      selectInput(ns("selectInputSE"),
        "Select a dataset for further information",
        choices = c("None", names(experiments(rv.infos$obj)))
      )
    })

    
    Get_QFeatures_summary <- reactive({

      req(rv.infos$obj)
      nb_assay <- length(rv.infos$obj)
      names_assay <- unlist(names(rv.infos$obj))
      pipeline <- metadata(rv.infos$obj)$pipelineType

      columns <- c("Number of assay(s)",
                   "List of assay(s)",
                   "Pipeline Type")

      vals <- c( if(is.null(metadata(rv.infos$obj)$pipelineType)) '-' else metadata(rv.infos$obj)$pipelineType,
                 length(rv.infos$obj),
                 if (length(rv.infos$obj)==0) '-' 
        else HTML(paste0('<ul>', paste0('<li>', names_assay, "</li>", collapse=""), '</ul>', collapse=""))
      )



      do <- data.frame(Definition= columns,
                       Value=vals
      )

      do
    })
    
    
    
    
    Get_SE_Summary <- reactive({
      req(rv.infos$obj)
      req(input$selectInputSE != "None")

     
        .se <- rv.infos$obj[[input$selectInputSE]]
        
        typeOfData <- metadata(.se)$typeDataset
        nLines <- nrow(.se)
        .nNA <- QFeatures::nNA(.se)
        percentMV <- round(.nNA$nNA[,'pNA'], digits = 2)
        nEmptyLines <-  length(which(.nNA$nNArows[,'pNA']==100))

        val <- c(typeOfData, nLines, percentMV, nEmptyLines)
        row_names <- c("Type of data",
                       "Number of lines",
                       "% of missing values",
                       "Number of empty lines")

        if (tolower(typeOfData) == 'peptide'){

          if(length(metadata(.se)$list.matAdj) > 0){
            adjMat.txt <- "<span style=\"color: lime\">OK</span>"
          } else{
            adjMat.txt <- "<span style=\"color: red\">Missing</span>"
          }

          if(!is.null(metadata(.se)$list.cc)){
            cc.txt <- "<span style=\"color: lime\">OK</span>"
          } else{
            cc.txt <- "<span style=\"color: red\">Missing</span>"
          }

          val <- c(val, adjMat.txt, cc.txt)
          row_names <- c(row_names, "Adjacency matrices", "Connex components")
        }


        do <- data.frame(Definition = row_names,
                         Value = val,
                         row.names = row_names)
        do
    })
    
    
    
    output$properties_ui <- renderUI({
      req(input$selectInputSE)
      req(rv.infos$obj)

      if (input$selectInputSE != "None") {
        checkboxInput(ns('properties_button'), "Display details?", value = FALSE)
      }
    })
    
    
    
    observeEvent(input$selectInputSE,{

      if (isTRUE(input$properties_button)) {
        output$properties_ui <- renderUI({
          checkboxInput(ns('properties_button'), "Display details?", value = TRUE)
        })
      }
      else{ return(NULL)}
    })
    
    
    # output$properties <- renderPrint({
    #   req(input$properties_button)
    # 
    #   if (input$selectInputSE != "None" && isTRUE(input$properties_button)) {
    # 
    #     data <- experiments(obj())[[input$selectInputSE]]
    #     metadata(data)
    #   }
    # })
    
    
    
    output$show_SE_ui <- renderUI({
      req(input$selectInputSE != "None")
      req(rv.infos$obj)

      data <- experiments(rv.infos$obj)[[input$selectInputSE]]
        MagellanNTK::format_DT_server('dt2',
          obj = reactive({Get_SE_Summary()})
          )
        tagList(
          MagellanNTK::format_DT_ui(ns('dt2')),
          br(),
          uiOutput(ns('info'))
        )
    })
    
    
    
    # output$info <- renderUI({
    #   req(input$selectInputSE)
    #   req(obj())
    #   
    #   if (input$selectInputSE != "None") {
    #     
    #     typeOfDataset <- Get_SE_Summary()["Type of data", 2]
    #     pourcentage <- Get_SE_Summary()["% of missing values", 2]
    #     nb.empty.lines <- Get_SE_Summary()["Number of empty lines", 2]
    #     if (pourcentage > 0 && nb.empty.lines > 0) {
    #       tagList(
    #         tags$h4("Info"),
    #         if (typeOfDataset == "protein"){
    #           tags$p("The aggregation tool
    #              has been disabled because the dataset contains
    #              protein quantitative data.")
    #         },
    #         
    #         if (pourcentage > 0){
    #           tags$p("As your dataset contains missing values, you should
    #              impute them prior to proceed to the differential analysis.")
    #         },
    #         if (nb.empty.lines > 0){
    #           tags$p("As your dataset contains lines with no values, you
    #              should remove them with the filter tool
    #              prior to proceed to the analysis of the data.")
    #         }
    #       )
    #     }
    #   }
    # })
    
    
    
    
    # NeedsUpdate <- reactive({
    #   req(obj())
    #   PROSTAR.version <- metadata(experiments(obj()))$versions$Prostar_Version
    #   
    #   if(compareVersion(PROSTAR.version,"1.12.9") != -1 && !is.na(PROSTAR.version) && PROSTAR.version != "NA") {
    #     return (FALSE)
    #   } else {
    #     return(TRUE)
    #   }
    # })
    
    
  })
  
  
}



#' @export
#' @rdname infos_dataset
#' 
infos_dataset <- function(obj){
  
  ui <- fluidPage(infos_dataset_ui("mod_info"))
  
  server <- function(input, output, session) {
    infos_dataset_server("mod_info", 
      obj = reactive({obj}))
  }

  app <- shiny::shinyApp(ui, server)
}
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Carregar Pacotes

pacman::p_load(DT, shiny, data.table, dplyr, ggplot2, plotly, shinyWidgets, shinydashboard)

#Setar diretorio
setwd("~/COBRADI")

#Estrutura da Página 
dashboardPage(
  ##Barra de cima 
  dashboardHeader(title = "COBRADI", 
                  titleWidth = 600,
                  tags$li(class = "dropdown",
                          tags$a(href = "https://www.ipea.gov.br/portal/index.php?option=com_content&view=article&id=39285",
                                 icon = "globe",
                                 "Site COBRADI", 
                                 target = "_blank"))
                  ),
  ##Barra Lateral
  dashboardSidebar(
    ##Menu da barra lateral 
    sidebarMenu(
      id = "sidebar",
      # 1 menu item
      menuItem("Dataset",
               tabName = "data",
               icon = icon("database")),
      # 2 menu item 
      menuItem("Visualização",
               tabName = "viz",
               icon = icon("char-line")),
      # 3 menu item 
      menuItem("Informações",
               tabName = "info",
               icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # 1 tab item
      tabItem(tabName = "data",
              #tab box
              tabBox(id = "t1", width = 12,
                     tabPanel("Sobre", icon = icon("adress-card"), h4("tabPanel-1 placeholder")),
                     tabPanel(title = "Base de Dados", icon = icon("adress-card"), h2("tabPanel-2 placeholder UI")),
                     tabPanel(title = "Estrutura", icon = icon("adress-card"), h2("tabPanel-3 placeholder UI")),
                     tabPanel(title = "Sumário Estatístico", icon = "adress-card", h2("tabPanel-4 placeholder UI"))
        )
      ),
      # 2 tab item ou landing page here
      tabItem(
        tabName = "viz",
        tabBox(id = "t2", width = 12,
               tabPanel(title = "Afastamentos por UF", value = "trends", h4("tabPanel-1 placeholder UI")),
               tabPanel(title = "Distribuição Amostral", value = "distribuicao", h4("tabPanel-1 placeholder UI"))
               )),
        
       # 3 tab item  
       tabItem(tabName = "infos",
               h1("Informações"),
               infoBox(title = "Contato",
                       icon = icon("envelope-square"),
                       subtitle = "Para mais informações e/ou feedback
                                   entre em contato: cobradi@ipea.gov.br
                                   [Respondemos em até 24h]"))
        )
      )
    )
  )
)

contagem_afastamentos <- afastamentos_2 |> 
                          dplyr::summarize(qtd_afastamentos = n() ) |> 
                          as.numeric()



#Barra Lateral 
barra_lateral <- dashboardSidebar(width = "250px",
                                  sidebarMenu(
                                    menuItem("Início",
                                             tabName = "inicio"),
                                    menuItem("Dashboard",
                                             tabName = "dashboard",
                                             icon = icon("dashboard", verify_fa = FALSE)),
                                    menuItem("Informações",
                                             tabName = "infos",
                                             icon = icon("info-circle"))
                                  ))

#Painel Principal 
painel_principal <- dashboardBody(

    tabItem(tabName = "dashboard",
            fluidRow(
              valueBox(subtitle = "Afastamentos",
                       value = nrow(afastamentos_2),
                       icon = icon("database")),
              infoBox(title = "", subtitle = "Afastamentos por Ano",
                      value = contagem_afastamentos,
                      icon = icon("list")),
              
              valueBoxOutput(outputId = "qtdUf")
              ),
            
            fluidRow(
              column(width = 12,
                     box(title = "Filtros", width = "100%",
                         column(width = 12,
                                box(width = "100%",
                                    awesomeCheckboxGroup(inline = TRUE,
                                                         inputId = "select_UF",
                                                         label = "Estados:",
                                                         choices = c("TODOS",
                                                                     unique(
                                                                       afastamentos_2$UF_da_UPAG_de_vinculacao)),
                                                         selected = "TODOS"))
                          ), 
                          column(width = 6,
                                   box(width = "100%",
                                       dateRangeInput(inputId = "data_abertura",
                                                      label =  "Data Abertura:", format = "dd-mm-yyyy",
                                                      start = min(as.Date(afastamentos_2$Ano_Mes_inicio_afastamento)),
                                                      end   = max(as.Date(afastamentos_2$Ano_Mes_inicio_afastamento)))
                                )
                          ), 
                          column(width = 6,
                                 box(width = "100%",
                                     selectizeInput(inputId = "afastamento",
                                                    label = "Tipo de Afastamento:",
                                                    choices = c("TODOS", unique(afastamentos_2$Descricao_do_afastamento)),
                                                    multiple = T, options = list(maxItems = 5),
                                                    selected = "TODOS")))
                        )
                  )
            ), #FIM fluidrow1
            
            fluidRow(
              column(
                width = 12,
                box(width = "100%",
                    plotlyOutput(outputId = "data", width = "100%"),
                    textOutput(outputId = "descData")
                    )
              )
            ), #FIM fluidrow2
            
            fluidRow(
              column(
                width = 6,
                box(width = "100%",
                    plotlyOutput(outputId = "porcentagem_afastamentos_descricao"))
              ),
              column(
                width = 6,
                box(width = "100%",
                    plotlyOutput(outputId = "afastamentos_por_ano"))
              )
            ), #FIM fluidrow3
            fluidRow(
              column(width = 12,
                     box(width = "100%", title = "Afastamentos por UF",
                         plotlyOutput(outputId = "UF"),
                         textOutput(outputId = "descUf")
          )
        )
      )
    )
  ), #FIM TAB ITEMS 
)   #FIM MAIN PANEL 

ui <- dashboardPage(header = cabecalho,
                    sidebar = barra_lateral,
                    body = painel_principal)

## front-end (tela que sera mostrada para o usuario)
ui2 <- fluidPage(
    # Titulo da Pagina 
    titlePanel("COBRADI"),
    sidebarLayout(
      sidebarPanel( 
        ##caixa de selecao da UF
        checkboxGroupInput(inputId = "select_UF",
                           label = "Estados:",
                           choices = c("TODOS", unique(afastamentos_2$UF_da_UPAG_de_vinculacao)),
                           selected = "TODOS"),
        
        ##calendario para selecionar data
        dateRangeInput(inputId = "data_abertura",
                       label =  "Data Abertura:", format = "dd-mm-yyyy",
                       start = min(as.Date(afastamentos_2$Ano_Mes_inicio_afastamento)),
                       end   = max(as.Date(afastamentos_2$Ano_Mes_inicio_afastamento))),
        
        ##selecionar descricao do afastamentos
        selectizeInput(inputId = "descricao_afastamento",
                       label = "Tipo de Afastamento:",
                       choices = c("TODOS", unique(afastamentos_2$Descricao_do_afastamento)),
                       multiple = T, options = list(maxItems = 5),
                       selected = "TODOS")
      ),
      
        mainPanel(
        ## grafico de linhas
        plotlyOutput(outputId = "data", width = "100%"),
        
        ## texto descritivo do grafico de linhas
        textOutput(outputId = "descData"),
        
        ## grafico UF
        plotlyOutput(outputId = "uf"),
        
        ## texto descritivo do grafico UF
        textOutput(outputId = "descUf"),

        ## grafico Quantidade de AFastamentos
        plotlyOutput(outputId = "afastamentos"),
        
        ## grafico ATENDIDA ANO
        plotlyOutput(outputId = "afastamentos_ano")
    )
  )
)
   
##back-end (o que o sistema irá executar para retornar ao usuário)
server <- function(input, output, session){
  dados_selecionados <- reactive({
    
    ##Filtro UF
    print(input)
    if(! "TODOS" %in% input$select_UF){
      afastamentos_2 <- afastamentos_2 |>
        filter(UF_da_UPAG_de_vinculacao %in% input$select_UF)
    }
    
    ##Filtro Descricao do Afastamento
    if(! "TODOS" %in% input$descricao_afastamento){
      afastamentos_2 <- afastamentos_2 |>
        filter(Descricao_do_afastamento %in% input$descricao_afastamento)
    }
    
    ## filtro DATA
    afastamentos_2 <- afastamentos_2 %>% 
        filter(as.Date(Ano_Mes_inicio_afastamento) >= input$data_abertura[1] &
               as.Date(Ano_Mes_inicio_afastamento) <= input$data_abertura[2])
    afastamentos_2
    
  })
  
  ##grafico de setores 
  
  output$data <- renderPlotly({
    df <- as.data.frame(table(afastamentos_2$Descricao_do_afastamento))
    pielabels <- c("Afas. Missão Exterior<br>com Ônus Limitado",
                    "Afastamento Missão no Exterior<br>Com Ônus",
                    "Afas. Prog. de Treinamento para<br>Congresso/Encontro Com Ônus",
                    "Afas. Prog. de Treinamento para<br>Congresso/Encontro Com Ônus Limitado",
                    "Afas. Viagem/Serviço<br>fora do país Com Ônus Limitado",
                    "Afas. Viagem/Serviço<br>fora do país Com Ônus")
    fig <- plot_ly(df, labels = ~pielabels, values = ~Freq, type = 'pie')
    fig <- fig %>% layout(title = (" Descrição do Afastamento"),
                          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
  })
  
  ##grafico linhas 
  output$afastamentos_ano <- ggplot(data = afastamentos_2021) +
    geom_line(aes(x = Mes_inicio_afastamento, group = 1), stat = "count", color = "blue", size = 1.2) +
    scale_x_discrete(labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez")) +
    theme_bw() +
    labs( x = "Mês início do afastamento", 
          y = "Quantidade de Afastamentos",
          title = "Afastamentos por Mês em 2021",
          caption = ("Fonte: Elaboração Própria através do RStudio")) +
    theme(plot.title = element_text(size = 14),
          axis.title.x = element_text(size = 11),
          axis.title.y = element_text(size = 11))
              
}

# Run the application 
shinyApp(ui = ui, server = server)

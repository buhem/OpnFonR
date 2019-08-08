library(shiny)
library(shinyBS)
library(tuneR)
library(phonTools)
library(seewave)
library(audio)
library(sound)
library(TextGridShiny)
library(stringr)
options(encoding = "UTF-8")
file(encoding = "UTF-8")


 name_inf = list(
  informateur_1 = list.files('www/informateur_1/', pattern="\\.wav$")
,
  informateur_2 = list.files('www/informateur_2/', pattern="\\.wav$")
  )


iconv(name_inf[[1]], to = "UTF-8")
iconv(name_inf[[2]], to = "UTF-8")




 AppBackgroundColor <- "#87CEFA"
 
 #"#D4D0C8" #http://www.w3schools.com/cssref/css_colors.asp

ui = fluidPage(
  tags$head( 
   tags$img(src = "lahmar.jpg", width = "100%", height = "auto", style="max-width:100%"),
   tags$link(rel = "stylesheet", type = "text/css", href = "style/css/cc-icons.min.css")
   ),
  


modalDialog(title="Welcome",
                
                  size = "m", # c("m", "s", "l"), 
                  easyClose = TRUE, 
                  fade = TRUE,
                  wellPanel(
                    style = paste0("background-color: ", AppBackgroundColor, ";",
                                   "border:4px; border-color:#458cc3;"
                    ),

                    HTML(
                      markdown::markdownToHTML(
                        fragment.only = TRUE,
                        text = paste0("Between 2015 and 2017, I carried out several fieldworks in the Sud-Oranais. Hence I have created this web-app, made with Shiny, in order to share a sample of my data and make my work available to scientific community.<br><br>The development of this interface follows on from my thesis that I achieved at the INALCO : <i>Linguistic description of endangered Berber varieties of Sud-Oranais (Algeria) - A dialectological, phonetic and phonological study of the consonantic system.</i> <br><br>The purpose of this application is to offer an interactive signal processing of a phonetic corpus on the alveolar rhotics."
                        ) # end paste0
                      ) # end markdownToHTML
                    ), # end HTML
                    hr(),
                    HTML(markdown::markdownToHTML(fragment.only=TRUE,text='&copy; 2018-2019 M. El Idrissi, Contact me at mohamed.elidrissi at inalco.fr <br> <i class="cc cc-SIX"></i>'))
                  ), # end wellPanel
                  footer = modalButton("Dismiss")
),

  tabsetPanel(  


     tabPanel("Sud-Oranais",                
       column(3,
       tags$div()
       ),
       column(4,
       align = "center",
       tags$div(id = 'sud_oranais', 
         tags$img(src="sud_oranais.gif")
       ),
      shinyBS:::bsPopover(id='sud_oranais', title=NULL, 
      content= paste('<p>Sud-Oranais is situated in the South-West of Algeria. This region has a wealth of history. We can find there a variety of different rock arts which are dated from Neolithic times, ancient Libyco-Berber scripts and so more historical traces (such as necropolis, cities remains, ...).</p> <p>In our time, the Sud-Oranais is subdivided into 3 wilayas (provinces) : Béchar, El-Bayadh and Naâma. Inside of these regional administrative entities dwell Arab peoples and Berber peoples. The Berbers represent only less than 7% percent of the population.</p> <p>Moreover, this variety of Berber is endangered. It is spoken only in few localities and mainly by older persons. This language has rarely been studied. André Basset is the last one to have gathered data from this area in the thirties.</p>', sep = ' '), 
      placement="below", trigger="hover",
      options = list(container = "body")
      )   #shinyBS #the image and shinyBS have to have the same ID
      ),   #column of image of sud_oranais
      column(3,
      tags$div()
      )
     ),   #tabpanel_sudoranais

    tabPanel("Alveolar Rhotic",   

  fluidRow(

    column(3,
          titlePanel("Data"),
          sidebarPanel(
           selectInput(inputId='speaker', label="Speakers", choices=as.character(names(name_inf)), selected=as.character(names(name_inf)[1])),
           selectInput(inputId='callType', label="Items", choices=as.character(name_inf[[1]]), selected=as.character(name_inf[[1]])[1]),
          
          
           tags$h5('Export', style = "font-weight: bold"),
           downloadButton(outputId = "saveAudio", label = "Save audio"),
           tags$br(), 
           tags$br(),
          
          tags$h5('Informations', style = "font-weight: bold"),
           actionButton("about", "About notation"),
           tags$br(), 
           tags$br(),

           actionButton("interface", "About the annotation interface"),

           width=40
         ),




    titlePanel("Settings"),
   

                                  sidebarPanel(
                                  radioButtons(inputId='spectrogram_or_spectrum', label="Sound visualization", choices=c("Spectrogram"="spectrogram", "Spectrum"="spectrum", "Signal"="signal"), selected='spectrogram', inline=TRUE, width=NULL),
tags$br(), tags$br(),

fluidRow(
             shinyBS::bsCollapse(id="spec_controls",
                                 shinyBS::bsCollapsePanel("Show spectrogram controls",
                                                          shinyBS:::bsPopover(id='specWindowLength', title=NULL, content='Window length for FFT transform (Gaussian)', placement="below", trigger="hover"),
                                                          sliderInput('specWindowLength', 'Window length, ms', value=4, min=0, max=100, step=1), #if i want that the two extrem move i can do value=c(0,4)

                                                          sliderInput('spec_ylim', 'Frequency range, kHz', value=5000, min=0, max=10000, step=500),
                                                          radioButtons(inputId='spec_colorTheme', label="Color scheme", choices=c("Colors"=TRUE, "Black & white"=FALSE), selected=FALSE, inline=TRUE, width=NULL),
                                                   
                                                          sliderInput('specContrast', 'Contrast', value=200, min=100, max=5000, step=100),
                                                          shinyBS:::bsPopover(id='specContrast', title=NULL, content='Regulates the contrast of the spectrogram. Contrast everything above this frequency', placement="below", trigger="hover"),
                                                          sliderInput('specBrightness', 'Brightness', value=40, min=10, max=90),
                                                          shinyBS:::bsPopover(id='specBrightness', title=NULL, content='Regulates the brightness of the spectrogram', placement="below", trigger="hover")
        
                                 )
             ),
                 shinyBS::bsCollapse(id="spectrum_controls",
                                 shinyBS::bsCollapsePanel("Show spectrum controls",
                                                        
                                                          sliderInput('sampling_Rate', 'Sampling rate, Hz', value=44100, min=12000, max=96000, step=4000),
                                                          sliderInput('time_duration', 's', value=c(0,0.012), min=0, max=2, step=0.002)

                                 )
             )
           ),
                                                                                 
                                               width=40
                                             )

                                  
    ),
 mainPanel(

    titlePanel("Results"),
    align = "center",
   
           fluidRow(
 
            div(id = "spec",

             style = "margin-right: -3em; margin-left: 5em;height:390px;",
             plotOutput('spectrogram')

             )
           ),
           
           fluidRow(

            div(id = "textgrid",
 
             style = "margin-right: -2em;",
             TextGridShinyOutput("mytextgrid")
  
             )
           ),
           
          fluidRow(

             div(id = "audiolisten",

               style = "margin-top:2em;margin-bottom:0em;height:50px;", 
               uiOutput("myAudio")

             )
           )



    ) #mainpanel


   
  ) #fluidrow_principal

    ), #tabpanel_rhotique
  
  tabPanel("Dialectology", 
  
   splitLayout( 
     
    column(6,
      titlePanel("Geolinguistic"),
      tags$div(id = 'geolinguistic', 
      tags$img(src="geolinguistic.gif")
      ),
      shinyBS:::bsPopover(id='geolinguistic', title=NULL, 
      content= paste('<p>I have conducted a geolinguistic study in order to show how',
      'the linguistic facts can vary in the Sud-Oranais.', 
      'I have chosen some variates belonging to the consonantal system. Our sample includes simple consonants as geminate consonants.</p> <p>Through the analysis of these sounds, it was mainly found that there is, for the simple consonants, a difference between frication and occlusion, and, for the geminate consonants, a difference between affrication and frication.</p> <p>The area distribution appears to follow a linguistical continuum, but we found exceptions. All of our results have been presented in the form of linguistic maps.</p>', sep = ' '), 
      placement="below", trigger="hover",
      options = list(container = "body")
      ) #shinyBS #the image and shinyBS have to have the same ID
      ), #column1
    
      
       
     #escape ' : berber\\'s
      
      column(6,
      titlePanel("Dialectometry"),
         tags$div(id = 'dialectometry', 
      tags$img(src="dialectometry.gif")
      ),
      shinyBS:::bsPopover(id='dialectometry', title=NULL, 
      content= paste("<p>The Sud-Oranais area contains exactly 16 Berber varieties. I have attempted to classify these dialectes. So, I have used various Data Science methods in order to establish the linguistic distance among these varieties.</p>", "<p>The exploration of these techniques, Supervised and Unsupervised learning algorithms, have shown that they are not necessarily suitable. The results can be suprinsingly differents.</p>", "<p>Nervertheless, in consideration of these outcomes, I notice that there are 3 large dialects which emerge. The latter have been named : septentrional haplolect, meridional haplolect and central haplolect.</p>",sep = ' '), 
      placement="below", trigger="hover",
      options = list(container = "body")
      ) #shinyBS
      ) #colum2
   
   ) #split layout 
  
  ) #tabpanel_dialectologie 
   


  ), #tabsetpanel
  

rm(list=ls(all.names = TRUE))


) #fluidpage



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


server = function(input, output, session) {


  myPars = reactiveValues(
                         'sound' = NULL,
                         'sound2' = NULL,
                         'audio_out' = NULL,
                          'tfile_sound_path' = NULL,
                          'name_inf_2' = NULL,
                          'xy' = NULL,
                          'speaker_out' = NULL
                            )



#############################################################################
#############################################################################
#############################################################################
#############################################################################
 




  observeEvent(input$speaker, {

     myPars$xy = NULL

    myPars$speaker_out = NULL
    myPars$name_inf_2 = list()
    
   
 myPars$name_inf_2 = list(
  informateur_1 = list.files('www/informateur_1/', pattern="\\.wav$")

    ,
  informateur_2 = list.files('www/informateur_2/', pattern="\\.wav$")

  )




 myPars$speaker_out = input$speaker


iconv(myPars$name_inf_2[[1]], to = "UTF-8")
iconv(myPars$name_inf_2[[2]], to = "UTF-8")



    if (myPars$speaker_out == "informateur_2") {

  
      updateSelectInput(session, inputId = 'callType',
                      choices = as.character(myPars$name_inf_2[['informateur_2']]),
                      selected = as.character(myPars$name_inf_2[['informateur_2']])[1]
                                            )

      myPars$tfile_sound_path <- file.path('www/informateur_2')
   

    } else {


      updateSelectInput(session, inputId = 'callType',
                      choices = as.character(myPars$name_inf_2[['informateur_1']]),
                      selected = as.character(myPars$name_inf_2[['informateur_1']])[1]
                                       )
                      
      myPars$tfile_sound_path <- file.path('www/informateur_1')

    }


     myPars$xy = as.character(myPars$name_inf_2[[myPars$speaker_out]])[1]  
     
     myPars$audio_out = paste0(as.character(myPars$speaker_out),'/',as.character(myPars$xy))                        
     myPars$sound2 = as.numeric(tuneR::readWave(paste0(as.character(myPars$tfile_sound_path),'/',as.character(myPars$xy)))@left)
     myPars$sound2 = myPars$sound2/32768 


  })



#############################################################################
#############################################################################
#############################################################################
#############################################################################






 
#############################################################################
#############################################################################
#############################################################################
#############################################################################





#######
## Start Show spectrogramme
#######

  observeEvent(input$callType, {

     myPars$xy = input$callType

     if (myPars$xy != "abrcan.wav") {
 
     myPars$audio_out = paste0(as.character(myPars$speaker_out),'/',as.character(myPars$xy))                        
     myPars$sound2 = as.numeric(tuneR::readWave(paste0(as.character(myPars$tfile_sound_path),'/',as.character(myPars$xy)))@left)
     myPars$sound2 = myPars$sound2/32768 #this number corresponds to what there is in PRAAT and phontools
    
     }

  
  
     duration = seewave::duration(myPars$sound2, 44100)
     duration = round(duration, digits = 2)

     updateNumericInput(session, "time_duration", max = duration)
 


     myPars$xygrid <- str_match(myPars$xy, ".*\\.") #match string from "." (firt letter) until "*" the character "." (\\.)


  })





  output$spectrogram = renderPlot({
   
    

    if (input$spectrogram_or_spectrum == 'spectrogram') {



    phonTools:::spectrogram(myPars$sound2, windowlength = input$specWindowLength,
             quality = TRUE, maxfreq = input$spec_ylim, fs = 44100,
             timestep = -1000, padding = 10, colors = input$spec_colorTheme,
             preemphasisf = input$specContrast, window = 'gaussian', windowparameter = 0.4,
             dynamicrange = input$specBrightness)
    
    phonTools::pitchtrack(myPars$sound2, fs = 44100, windowlength = 50, f0range = c(60,300), minacf = .5, timestep = 1, addtospect = TRUE)

 
  
    } else if (input$spectrogram_or_spectrum == 'signal') {
    
    
    #signal

    seewave::oscillo(myPars$sound2, f = 44100, scroll = NULL,
                 zoom = FALSE, k=1, j=1, cex = 1,
                 labels = TRUE, tlab = "Time (s)", alab = "Amplitude",
                 byrow = FALSE, identify = FALSE, nidentify = NULL,
                 plot = TRUE, colwave = "black",
                 coltitle = "black", cextitle = 1.2, fonttitle = 2,
                 collab = "black", cexlab = 1, fontlab = 1,
                 colline = "black",
                 colaxis = "black", cexaxis = 1, fontaxis = 1,
                 coly0 = "lightgrey",
                 tcl = 0.6, title = FALSE, xaxt="s", yaxt="n", type="l", bty = "o")



    } else {

     #spectrum

      seewave::meanspec(myPars$sound2, 
      f = input$sampling_Rate, 
      dB = 'max0',  wn = "hanning",
      wl = 512, norm = TRUE,
      from=input$time_duration[1], to=input$time_duration[2],
      flim=c(0,input$spec_ylim/1000), alim=c(-80,20),
       main = 'Spectrum')
    

    }


  })





#######
## End Show spectrogramme
#######


#############################################################################
#############################################################################
#############################################################################
#############################################################################




#######
## start Show audio
#######


  output$myAudio = renderUI({
 

        tags$audio(src = myPars$audio_out, type = "audio/wav", autoplay = NA, controls = NA)

 
  })

#######
## end Show audio
#######



#############################################################################
#############################################################################
#############################################################################
#############################################################################



#######
## start Show annotation
#######



output$mytextgrid <- renderTextGridShiny({

  TextGridShiny(paste0(as.character(myPars$tfile_sound_path),'/',as.character(myPars$xygrid[1]),'TextGrid'))
  
})



#######
## end Show annotation
######



#############################################################################
#############################################################################
#############################################################################
#############################################################################



#######
## start Save audio
######

  output$saveAudio = downloadHandler(

    filename = function(x) {
    
    paste0(input$callType)

    },

    content = function(x) {
    
    file.copy(paste0('www/',input$speaker,'/',input$callType),x)

    }

  )

#######
## end Save audio
######



#############################################################################
#############################################################################
#############################################################################
#############################################################################



#######
## start about
######

  observeEvent(input$about, {

    showNotification(

        HTML("<style>
      table #tg-9hbo{vertical-align:top;}
      table {text-align:center;}
      </style>
      The notation used in the filename is unusual, because it's a transcription that I have created. The reason of this choice is that Shiny doesn't allow the use of the Unicode characters in the filename. Here is what the notation looks like : <br><center><table><tr id='tg-9hbo'><th>Notation used&nbsp;&nbsp;&nbsp;</th><th>IPA</th></tr><tr><td>r</td><td>&#x027E</td></tr><tr><td>rr</td><td>r</td></tr><tr><td>J</td><td>&#x0292</td></tr><tr><td>c</td><td>&#x0283</td></tr><tr><td>R</td><td>&#x027E&#x02E4</td></tr><tr><td>RR</td><td>r&#x02E4</td></tr></table><center>"),
        duration = 15,
      closeButton = TRUE,
      type = 'message'
      )
  })


    observeEvent(input$interface, {

    showNotification(

        HTML("This annotation interface comes from the widget <em>Textgrid</em> that I have created. The latter can be downloaded at this address : <a href='https://github.com/buhem/TextGridWidget/'>https://github.com/buhem/TextGridWidget/</a>"),
        duration = 15,
      closeButton = TRUE,
      type = 'message'
      )
  })


#######
## end About   
######



#############################################################################
#############################################################################
#############################################################################
#############################################################################



#######
## start geolinguistic Images 
######





#######
## end geolinguistic Images 
######

on.exit(closeAllConnections())


}





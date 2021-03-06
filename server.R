#library(reshape2)
options(shiny.maxRequestSize=30*1024^2) 
server <- function(input, output) {
####################################################
output$DRC_grep <- renderTable({
req(input$file1)
diffdm0 <- read.csv(input$file1$datapath, header = TRUE)
lpo <- diffdm0
##
#merge column 2 6 7 17 18
lpo2 <- cbind(lpo[2],lpo[17],lpo[18],lpo[6],lpo[7],lpo[11])
###write.csv(x = lpo2, row.names = FALSE, file = paste(format(Sys.time(), "%Y%m%d_%H"), "_lpo2.csv", sep = "") )
#filter Tech Variant != blank
lpo2_22fdx <- lpo2[lpo2[6]!="", ]
colnames(lpo2_22fdx)[6] <- c("TV")
##2 ways to do filter
###lpo2_22fdx <- lpo2_22fdx[lpo2_22fdx[6]=="22FDX", ]
##or do OR_filter
###lpo2_22fdx <- lpo2_22fdx[ which( lpo2_22fdx[6]=="28SLP" | lpo2_22fdx[6]=="28SLP;28SLPHV" ), ]
##or grep contain
lpo2_22fdx <- lpo2_22fdx[grep(input$text1, lpo2_22fdx$TV),]
##or grep not SLPHV
#lpo2_22fdx <- lpo2_22fdx[grep("28SLPHV", lpo2_22fdx$TV, invert = TRUE),]
#filter Layer Status == Active
lpo2_22fdx_act <- lpo2_22fdx[lpo2_22fdx[4]=="Active", ]
#filter Layer Category != 
lpo2_22fdx_act_cate <- lpo2_22fdx_act[lpo2_22fdx_act[5]!="Cadence Auxiliary", ]
lpo2_22fdx_act_cate <- lpo2_22fdx_act_cate[lpo2_22fdx_act_cate[5]!="Generated Mask", ]
lpo2_22fdx_act_cate <- lpo2_22fdx_act_cate[lpo2_22fdx_act_cate[5]!="Unknown", ]
###write.csv(x = lpo2_22fdx_act_cate, row.names = FALSE, file = paste(format(Sys.time(), "%Y%m%d_%H"), "_lpo2_22fdx_act_cate.csv", sep = "") )
#re-bind 3 columns
lpo2_22fdx_act_cate_3cols <- cbind(lpo2_22fdx_act_cate[1],lpo2_22fdx_act_cate[2],lpo2_22fdx_act_cate[3])
#remove duplicates
lpo2_22fdx_act_cate_dedup <- unique(lpo2_22fdx_act_cate_3cols) 
#re-order col 2 & 3
lpo2_22fdx_act_cate_dedup <- lpo2_22fdx_act_cate_dedup[ order(lpo2_22fdx_act_cate_dedup[,2], lpo2_22fdx_act_cate_dedup[,3]), ]
#remove last row -> why?
lpo2_22fdx_act_cate_dedup <- lpo2_22fdx_act_cate_dedup[-dim(lpo2_22fdx_act_cate_dedup)[1],]
#will rbind c("Customer_Reserved_layers", "2000-2300", "0-9999")
last_row <- matrix(c("Customer_Reserved_layers", "2000-2300", "0-9999"), nrow = 1)
colnames(last_row) <- colnames(lpo2_22fdx_act_cate_dedup)
allowlayer1 <- rbind(lpo2_22fdx_act_cate_dedup, last_row)
###write.csv(x = allowlayer1, row.names = FALSE, file = paste(format(Sys.time(), "%Y%m%d_%H"), "_allow_layer_ans.csv", sep = "") )
allowlayer1
####
})
####https://shiny.rstudio.com/articles/download.html
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
	#https://shiny.rstudio.com/reference/shiny/0.14/downloadHandler.html
      paste("data-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(output$DRC_grep(), file, row.names = FALSE)
    }
  )
####
}

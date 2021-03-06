do_unzip <- function()#unzip zip files
{
    zfiles <- shell("dir *.zip /B", intern = T)
    for(i in 1 :length(zfiles))
    {
        unzip(zfiles[i], exdir = "tmp")
    }
}

del_unzip <- function()#delete unzipped files
{
    cmd <- paste("rmdir /S /Q ", "tmp", sep = "")
    shell(cmd)
}

form_rec <- function(rec, n) #get the universay format of rec
{
    if(!is.data.frame(rec)) rec <- as.data.frame(rec)
    if(sum(as.numeric(row.names(rec)), na.rm = TRUE)>0) row.names(rec) <- NULL 
    i <- sapply(rec, is.factor)
    rec[i] <- lapply(rec[i], as.character)
    i <- sapply(rec, is.character)
    i[length(i)] <- FALSE
    rec[i] <- lapply(rec[i], as.numeric)
    rec <- cbind(n, rec)
    colnames(rec) <- c_names
    rec
}

getkml<-function(sd, sc, anames)
{
    out <- anames
    sd  <- as.character(sd)
    tmp <- str_sub(sd, start=325, end=-200)
    tmp <- unlist(str_split(tmp, "</td> <td width=\"205\">"))
    tmp <- unlist(str_split(tmp, "</td> </tr> <tr> <td width=\"210\">"))
    tmp <- unlist(str_split(tmp, 
        "</td> </tr> <tr bgcolor=\"#EBEBEB\"> <td width=\"210\">"))
    len <- length(tmp)
    j <- 1
    for(i in 1:length(anames))
    {
        while(j < len)
        {
            #if(str_detect(tmp[j], anames[i]))
            if(tmp[j] == anames[i])
            {
                out[i] <- tmp[j+1]
                j <- j + 2
                break
            }
            j <- j + 2
        }
    }
    c(out,sc[1:2])
}

print_0 <- function(rec)
{
    print(paste(sum(rec == 0), "out of", length(rec), "is 0", sep = " "))
}

getkml2 <- function(sd, sc, anames)
{
    out <- anames
    sd  <- as.character(sd)
    tmp <- str_sub(sd, start=103, end = -24)
    tmp <- unlist(str_split(tmp, " </tr><tr bgcolor=\"\"> "))
    tmp <- unlist(str_split(tmp, " </tr><tr bgcolor=\"#E3E3F3\"> "))
    tmp <- unlist(str_split(tmp, "</th> <td>"))
    len <- length(tmp)
    seqt <- seq(1, len, by = 2)
    tmp[seqt] <- str_sub(tmp[seqt], start = 5)
    tmp[seqt + 1] <- str_sub(tmp[seqt+1], end = -6)    
    j <- 1
    for(i in 1:length(anames))
    {
        while(j < len)
        {
            if(anames[i] == tmp[j])
            {
                out[i] <- tmp[j + 1]
                j <- j + 2
                break
            }
            j <- j + 2
        }
    }
    c(out, sc[1:2])   
}

getcoords <- function(coords)
{
    xmax <- max(coords[, 1])
    xmin <- min(coords[, 1])
    ymax <- max(coords[, 2])
    ymin <- min(coords[, 2])
    c(xmax,xmin, ymax, ymin)
}

get_coords2 <- function(no)
{
    xpath <- c("//a[@id='ctl00_ContentPlaceHolder1_hlMapit']")
    url <- "http://www2.des.state.nh.us/DESOnestop/WLSDetail.aspx?ID="
    url <- paste0(url, no) 
    map <- crawler1(url,xpath, content = "href")
    map <- as.character(map)
    ll  <- as.numeric(unlist(str_split(str_sub(map, str_locate(map, 
        "q=")[, 2]+1), ",")))
    data.frame(WRB_NUMBER = no, lon = ll[2], lat = ll[1]) 
}

qsec_box <- function(box, qsec)
{
    xdis <- box$xmax - box$xmin
    ydis <- box$ymax - box$ymin
    box2 <- box
    if(qsec == "NW")
    {
        box2$xmax <- box$xmin + xdis/2
        box2$ymin <- box$ymax - ydis/2
    }else if(qsec == "NE")
    {
        box2$xmin <- box$xmax - xdis/2
        box2$ymin <- box$ymax - ydis/2
    }else if(qsec == "SW")
    {
        box2$xmax <- box$xmin + xdis/2
        box2$ymax <- box$ymin + ydis/2   
    }else if(qsec == "SE")
    {
        box2$xmin <- box$xmax - xdis/2
        box2$ymax <- box$ymin + ydis/2
    }else if(qsec == "N")
    {
        box2$ymin <- box$ymax - ydis/2    
    }else if (qsec == "S")
    {
        box2$ymax <- box$ymin + ydis/2
    }else if(qsec == "W")
    {
        box2$xmax <- box$xmin + xdis/2    
    }else if (qsec == "E")
    {
        box2$xmin <- box$xmax - xdis/2
    }
    box2
} 

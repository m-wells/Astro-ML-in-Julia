#=
    testDrivers
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## A program to test the drivers that preprocess the data

include("helperFuncs.jl")
include("lightcurveFuncs.jl")
include("fitsHeaderData.jl")
include("preProcessingMain.jl")

function testLCDriver(settingsFile::String,headerKeywordList::String,chunkNum::Int64)
#    settingsFile = "CREATIVE_STATION_SETTINGS.txt"
#    chunkNum = 1
    mySettings = initializeSettings(settingsFile,headerKeywordList,chunkNum)
    
    statusIO = open("STATUS.txt","r+")

    allKIDs = dir_KIDs(mySettings.fits_dir)
    firstKID = allKIDs[1]

    lightcurveDriver(mySettings,firstKID,allKIDs,chunkNum,statusIO)
end


function testMain()

    chunkNum = 1
    settingsFile = "CREATIVE_STATION_SETTINGS.txt"
    statusFile = "STATUS_1.txt"
    headerKeywordList = "headerKeyWordList.txt"

    main(chunkNum,settingsFile,statusFile,headerKeywordList)
end

#=
    combineFeatures
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>
                     Mark Wells    <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

include("preProcessingMain.jl")
include("helperFuncs.jl")
using PyCall
@pyimport sklearn.preprocessing as preprocessing


function combineFeatures(feat_dir::String)

    ## Get a list of all the header features files in the given directory
    featureFiles = readdir(feat_dir)

    ## Go through all the files and vcat the features of the list
    for file in featureFiles 

        ## If the file is the first features file being processed
        if file == featureFiles[1]
            ## Get the data from the file
            kids,features = getDataFromFile(feat_dir,file)
        else
            ## Get the data from the file
            tempkids,tempfeats = getDataFromFile(feat_dir,file)
            kids = vcat(kids,tempkids)
            features = vcat(features,tempfeats)
        end
    end

    ## Sort the features by the Kepler ID number
    kids,features = sortData(kids,features)
    features = imputeData(features)


    array = hcat(kids,features)
    lastcol = size(array)[2]-1
    file = feat_dir[1:lastcol] * ".csv"
    println("writing: ",file)
    writecsv(file,array)
    return kids,features
end



function matchAndCombine(kids1,feats1,kids2,feats2)
    inds = indexin(unique(kids1),kids1)
    kids1 = kids1[inds]
    feats1 = feats1[inds,:]

    inds = indexin(unique(kids2),kids2)
    kids2 = kids2[inds]
    feats2 = feats2[inds,:]

    inds = findin(kids1,kids2)
    kids1 = kids1[inds]
    feats1 = feats1[inds,:]

    inds = findin(kids2,kids1)
    kids2 = kids2[inds]
    feats2 = feats2[inds,:]

    println(size(kids1))
    println(size(kids2))
    @assert(kids1 == kids2) 

    feats = hcat(feats1,feats2)
    return kids1,feats
end



function combinationDriver()
    println("reading settings")
#    settings = initializeSettings("SETTINGS_studio.txt","headerKeyWordList.txt",1)
    settings = initializeSettings("CREATIVE_STATION_SETTINGS.txt","headerKeyWordList.txt",1)
#    println("combining head features")
#    headkids,headfeats = combineFeatures(settings.header_dir)
#    println("combining lc features")
#    lckids,lcfeats = combineFeatures(settings.flc_dir)
    file = "flcFeatsComb.csv"
    println("reading: ",file)
    array = readcsv(file,String)
    flckids = array[:,1]
    flcfeats = array[:,2:end]

    file = "headFeatsComb.csv"
    println("reading: ",file)
    array = readcsv(file,String)
    headkids = array[:,1]
    headfeats = array[:,2:end]

    println("begun match and combine head and lc")
    kids,feats = matchAndCombine(headkids,headfeats,flckids,flcfeats)

    println("reading galex")
    galexkids,galexfeats = sortGalex("galexData.csv")

    println("begun match and combine with galex")
    kids,feats = matchAndCombine(kids,feats,galexkids,galexfeats)
#    writecsv("/home/mark/kepler_ML/cross_ref_feats.csv",feats)

    table = hcat(kids,feats)
    writecsv("/home/CREATIVE_STATION/Astro-ML-in-Julia/cross_ref_feats_plus_kid.csv",table)
end


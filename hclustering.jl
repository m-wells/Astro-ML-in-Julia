#=
    hclustering
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

include("helperFuncs.jl")

using PyCall
@pyimport scipy.spatial.distance as dist
@pyimport scipy.cluster.hierarchy as hier
@pyimport sklearn.neighbors as neighbors
@pyimport sklearn.cluster as cluster
@pyimport sklearn.metrics as metrics
using PyPlot


function performCluster(features,kVal,con_matrix)
    estimator = cluster.AgglomerativeClustering(n_clusters=kVal,connectivity=con_matrix)

    predictedLabels = estimator[:fit_predict](features)
    return predictedLabels

end


function evaluateCluster(features,predictedLabels)
#    println("sample size: ",size(features)[1])
    sample = sqrt(size(features)[1])
    sampleSize = int(sample)
#    println("sample size for silhouette: ",sampleSize, typeof(sampleSize))

    score = metrics.silhouette_score(features,predictedLabels,sample_size=sampleSize)

    return score

end


function testVariousK(features,con_matrix)
    ## Want a range from from 10 to 30 inclusive
    kList = range(10,1,21)
    scores = Array(Float64,length(kList))

    ## Perform clustering on a variety of k values
    maxscore = 0.0
    bestK = 0

    for i = 1:length(kList)
        try
            labels = performCluster(features,kList[i],con_matrix)
            score = evaluateCluster(features,labels)
            scores[i] = score

            ## Keep track of the best silhouette score
            ## and the associated k value
            if score > maxscore
                maxscore = score
                println("Current max score: ", maxscore)
                bestK = kList[i] 
            end
        end
    end

    println("Now writing silhouette scores file")
    sil_scores_file_name = "/home/CREATIVE_STATION/Astro-ML-in-Julia/sil_scores.csv"
    writecsv(sil_scores_file_name,scores)

    println("Now writing kList file")
    kList_file_name = "/home/CREATIVE_STATION/Astro-ML-in-Julia/kList.csv"
    writecsv(kList_file_name,kList)

    return bestK

end


## Collects the KIDs that belong to each cluster and writes them out to a file
## Each line in the resulting file is one cluster's KIDs
function clusterMembership(kids,labels)
    lenProc = length(kids)
    println("lenProc: ", lenProc)

end


## Plot the feature space given two features
## The function parameter indices are column numbers
## From 1 to 9, the number of features
function plotFeatures(features,feat_1_ind::Int64,feat_2_ind::Int64)
    x = features[:,feat_1_ind]
    y = features[:,feat_2_ind]

    clf()
    scatter(x,y)
    show()

end

function test_for_to()
    normFeatsFile = "norm_cross_ref_feats_plus_kid.csv"
    kids,feats = getFeatures(normFeatsFile)

    feats_1 = int(linspace(1,15,15))
    feats_2 = int(linspace(1,15,15))

    combArr = hcat(feats_1,feats_2)

    plotFeatures(feats,4,10)


end


function clusteringDriver()
    println("begun process")
    normFeatsFile = "norm_cross_ref_feats_plus_kid.csv"
    kids,feats = getFeatures(normFeatsFile)

    nkids = size(kids)[1]
    n =  int(sqrt(nkids))
#    n = int(nkids/50)
#    n = nkids
    println("The overall sample size is: ", n)

    inds = randperm(nkids)[1:n]
    sample = feats[inds,:]
    sample_kids = kids[inds,:]
#    println("sample_kids: ", sample_kids)


    ## Include connectivity constraints to only merge the nearest neighbors
    numNeighbors = 30
    connectivity_matrix = neighbors.kneighbors_graph(sample,numNeighbors)

    ## Test to see which k value is the best
    bestK = testVariousK(sample,connectivity_matrix)
    println("best k: ", bestK)

    ## Get the labels of the best k
    labels = performCluster(sample,bestK,connectivity_matrix)


    dist_matrix = dist.pdist(sample,"euclidean")
    link_matrix = hier.linkage(dist_matrix)

    color_thres = 0.9*maximum(link_matrix[:,2])
    R = hier.dendrogram(link_matrix,show_leaf_counts=true,p=50,
        truncate_mode="level",distance_sort="ascending",leaf_font_size=13)
    xlabel("Number of Members",fontsize=15)
    ylabel("Normalized Distance Between Children Nodes",fontsize=15)
    title("Dendrogram of Hierarchical Clustering Results",fontsize=17)

    createBarGraph(labels)

end

#clusteringDriver()
test_for_to()

import time

def pm4pyComputeTime(eventLog):
    start = time.time()
    from pm4py.objects.log.importer.xes import importer as xes_importer
    log = xes_importer.apply(eventLog)
    from pm4py.algo.discovery.dfg import algorithm as dfg_discovery
    from pm4py.visualization.dfg import visualizer as dfg_visualization
    dfg = dfg_discovery.apply(log, variant=dfg_discovery.Variants.FREQUENCY)
    gviz = dfg_visualization.apply(dfg, log=log, variant=dfg_visualization.Variants.FREQUENCY)
    # dfg_visualization.view(gviz)
    end = time.time()
    print ("Time elapsed to get data and DFG visualization:", end - start)

pm4pyComputeTime(r'bpi2012.xes')
# pm4pyComputeTime(r'bpi2013.xes')
# pm4pyComputeTime(r'bpi2014.xes')
# pm4pyComputeTime(r'bpi2015.xes')
# pm4pyComputeTime(r'bpi2017.xes')

"""
Various Functions to calculate various information theoretic quantities
"""

#Functions to import
import numpy as np

#Begin Functions
def calcPMF(X, bins=10):
    '''
    Function to convert a 1D vector as a numpy array to a discrete Probability Mass Function (PMF)
    Requires numpy to be imported as np
    
    Input
    -----
    X = 1D vector of data as numpy array
    
    bins = Str for np.histogram (np >= 1.11) or number of bins to create histogram for PMF
    
    Output
    ------
    PMF = Normalized Probability Mass Function (PMF) so the sum is approximately 1
    
    Edges = Edges calculated from np.histogram function for PMF
    '''
    ver = [int(x) for x in np.version.version.split('.')[:2]]
    if ver < [1, 11]:
        bins = 10 #Default Bin Behavior if numpy version is less than version 1.11
        
    N = float(X.shape[0])
    Hist = np.histogram(X, bins=bins)
    PMF = Hist[0].astype('float64')/Hist[0].astype('float64').sum() #Normalize values from hist function (x[0]) by N so sum of PMF is at/near 1
    Edges = Hist[1].astype('float64') #Take Bin Edges from hist function (x[1])
    return PMF, Edges

def calcJointPMF(X, Y, bins=10):
    '''
    Function to convert two 1D trace as numpy arrays to a joint distribution Probability Mass Function (PMF)
    Requires numpy to be imported as np
    
    Input
    -----
    X = 1D vector of data as numpy array
    
    Y = 1D vector of data as numpy array
    
    bins = Number of bins to create histogram for PMF
    
    Output
    ------
    JPMF = Normalized Joint Probability Mass Function (PMF) so the sum is approximately 1
    
    Edges = Edges calculated from np.histogram function for PMF given as [XEdges, YEdges]
    '''
    Hist2d = np.histogram2d(X,Y, bins=bins)
    
    JPMF = Hist2d[0].astype('float64')/Hist2d[0].astype('float64').sum() #Normalize values from hist function (x[0]) so sum of JPMF is at/near 1
    Edges = Hist2d[1].astype('float64') #Take Bin Edges from hist function (x[1])
    
    return JPMF, Edges

def calcEntropy(pmf):
    '''
    Function to calculate Shannon Entropy from a Probability Mass Function as a 1D numpy array   
    Requires numpy to be imported as np
    
    Input
    -----
    pmf = 1D numpy array that is a discrete probability mass function (pmf) or (n,k) array and returns values over last axis
    
    Output
    ------
    H = Shannon Entropy in bits as calculated by sum(-P * log2(P)) where P is the probability at each point
    '''
    eps = np.finfo(float).eps #Min Value so no logs of 0.
    H = np.nansum(-pmf * np.log2(pmf.clip(eps)), axis=-1)
    return H

def calcJointEntropy(jpmf):
    '''
    Function to calculate Shannon Entropy from a Joint Probability Mass Function as a 2D numpy array   
    Requires numpy to be imported as np
    
    Input
    -----
    jpmf = 2D numpy array that is a joint probability mass function (pmf)
    
    Output
    ------
    H = Shannon Entropy in bits as calculated by sum(sum(-Pxy * log2(Pxy))) where P is the probability at each point
    '''
    eps = np.finfo(float).eps #Min Value so no logs of 0.
    H = np.nansum(np.nansum(-jpmf * np.log2(jpmf.clip(eps))))
    return H

def calcMutualInformation(jpmf):
    '''
    Function to calculate Mutual Information from a Joint Probability Mass Function as a 2D numpy array   
    Requires numpy to be imported as np
    
    Input
    -----
    jpmf = 2D numpy array that is a joint probability mass function (pmf).  Assumes X is first axis and Y is second axis
    
    Output
    ------
    I = Mutual Information in bits as calculated as H(X) + H(Y) - H(X,Y) where H is the entropy and x & y are random variables
    '''
    XPMF = jpmf.sum(axis=1)
    YPMF = jpmf.sum(axis=0)
    
    H_X = calcEntropy(XPMF)
    H_Y = calcEntropy(YPMF)
    H_XY = calcJointEntropy(jpmf)
    
    I = H_X + H_Y - H_XY
    return I

def calcConditionalEntropy(jpmf, axis=1):
    '''
    Function to calculate Conditional Entropy from a Joint Probability Mass Function as a 2D numpy array   
    Requires numpy to be imported as np
    
    Input
    -----
    jpmf = 2D numpy array that is a joint probability mass function (pmf)
    
    axis = Axis to calculate with respect to.  Corresponds to X, for X|Y
    
    Output
    ------
    HX_Y = Conditional Entropy of X given Y calculated from H(X|Y) = H(X) - I(X,Y) where H is the entropy, I is mutual information
    and x & y are random variables
    '''
    X = jpmf.sum(axis=axis)
    H_X = calcEntropy(X)
    I = calcMutualInformation(jpmf)
    
    HX_Y = H_X - I
    return HX_Y

def functionTests():
    # Example 2.2.1 from Elements of Information Theory (Cover & Thomas)
    XPMF=np.array([.5,.25,.125,.125])
    YPMF=np.array([.25,.25,.25,.25])
    JPMF=np.array(([.125, .0625, .03125, .03125],
                   [.0625, .125, .03125, .03125],
                   [.0625, .0625, .0625, .0625],
                   [.25, 0, 0, 0]), dtype=float)
    H_X = calcEntropy(XPMF)
    H_Y = calcEntropy(YPMF)
    H_XY = calcJointEntropy(JPMF)
    MI = calcMutualInformation(JPMF)
    HX_Y = calcConditionalEntropy(JPMF)

    return H_X, H_Y, H_XY, MI, HX_Y

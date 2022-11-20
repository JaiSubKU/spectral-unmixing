function [ varargout ] = smooth2photon(numchannels,t,v,y,nx,ny)


if nargin==6
     h = [0.0039    0.0156    0.0234    0.0156    0.0039;
        0.0156    0.0625    0.0938    0.0625    0.0156;
        0.0234    0.0938    0.1406    0.0938    0.0234;
        0.0156    0.0625    0.0938    0.0625    0.0156;
        0.0039    0.0156    0.0234    0.0156    0.0039];   % 2D B3-Spline filter
   

     t_sm = imfilter(t,h);
     v_sm = imfilter(v,h);
     y_sm = imfilter(y,h);
    varargout{1}=t_sm;
    varargout{2}=v_sm;
    varargout{3}=y_sm;
else
    return
end


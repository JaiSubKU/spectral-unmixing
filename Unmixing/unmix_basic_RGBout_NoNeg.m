function [RGB] = unmix_basic_RGBout_NoNeg(ch1,ch2,ch3,m,i,smoothon)


nx=size(ch1,1);
ny=size(ch1,2);

for k=1:nx
    um=m\[double(ch1(k,:,i)); double(ch2(k,:,i)); double(ch3(k,:,i))];
    t(k,:)=um(1,:);
    v(k,:)=um(2,:);
    y(k,:)=um(3,:);
end

%This section here will do non negative factorization for any pixels that
%returned a negative pixel value. 

   neg=unique([find(t<0);find(v<0);find(y<0)]);%Get indexed locations for all negative values in any image
   ch1i=ch1(:,:,i);
   ch2i=ch2(:,:,i);%Make a copy of just the image we are looking at here so that the index locations work
   ch3i=ch3(:,:,i);
    
   vals=[ch1i(neg)';ch2i(neg)';ch3i(neg)']; % in same format as above where each column is variables across channels for 1 pixel
   
   for ind =1:length(vals)
   um(:,ind)=lsqnonneg(m, double(vals(:,ind))); %(C*x-d) = d=C*x  =  Channel = coef matrix * realvalue of fluorophore
   end
     
   %reassign non neg values
   t(neg)=um(1,:);
   v(neg)=um(2,:);
   y(neg)=um(3,:);

   % error checking statements
% disp('  ');
% disp(['Zslice ', num2str(i)]);
% disp(['Diagnostics concerning fit of unmixing. A lot of negatives here is bad: ', num2str(sum(sum([t<0,v<0,y<0])))]);
% disp(['Median value of negative values: ',num2str(median(median([t(t<0);v(v<0);y(y<0)]))) ]);
% 
% a=sum(sum([ch1(:,:,i),ch2(:,:,i),ch3(:,:,i)]));
% b=sum(sum([t,v,y]));
% c=abs(a-b);
% disp(['Value of entire signal pre unmixing: ',num2str(a),' Value after: ',num2str(b),'  DIFFERENCE: ', num2str(c), '   % change from orig: ',num2str(c/a*100)]);
% 


%Smoothing
if smoothon==1
    [t_sm, v_sm, y_sm]=smooth2photon(3,t,v,y,nx,ny);
else
    t_sm=t;
    v_sm=v;
    y_sm=y;
end

% 
% 
% a=sum(sum([ch1(:,:,i),ch2(:,:,i),ch3(:,:,i)]));
% b=sum(sum([t_sm,v_sm,y_sm]));
% c=abs(a-b);
% disp(['Value of entire signal pre unmixing: ',num2str(a),' Value after smoothing: ',num2str(b),'  DIFFERENCE: ', num2str(c), '   % change from orig: ',num2str(c/a*100)]);
% 
% 


for ch=1:3
    if ch==1
        aimage = (t_sm(:,:)');
    elseif ch==2
        aimage = (v_sm(:,:)');
    else
        aimage = (y_sm(:,:)');
    end
    RGB(:,:,ch)=aimage;
end
end


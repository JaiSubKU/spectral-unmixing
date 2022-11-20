function [RGB] = unmix_basic_RGBout(ch1,ch2,ch3,m,i,smoothon)


nx=size(ch1,1);
ny=size(ch1,2);

for k=1:nx
    um=m\[double(ch1(k,:,i)); double(ch2(k,:,i)); double(ch3(k,:,i))];
    t(k,:)=um(1,:);
    v(k,:)=um(2,:);
    y(k,:)=um(3,:);
end

%Smoothing
if smoothon==1
    [t_sm, v_sm, y_sm]=smooth2photon(3,t,v,y,nx,ny);
else
    t_sm=t;
    v_sm=v;
    y_sm=y;
end

for ch=1:3
    if ch==1
        aimage = (t_sm(:,:));
    elseif ch==2
        aimage = (v_sm(:,:));
    else
        aimage = (y_sm(:,:));
    end
    RGB(:,:,ch)=aimage;
end
end


%No Unmixing matrix 3 color
%C1 is dominant color in channel 1, C2 channel 2
% %C1toch1, %C2toCh1, etc
% %C1toch2, %C2toCh2
% %C1toch3, %C2toCh3
m=[.48,.02,.04;
.47,.84,.12;
.05,.14,.84;]

RGBreorder=[3,2,1]; %flips channels below to match colors you desire in imageJ right side has pmts and spots correspond to red green blue

[file,folder]=uigetfile('*.tif*');
numLoc=strfind(file,'.');%find filename before extension
filebase=fullfile(folder,file(1:numLoc(1)-1));
fileout=[filebase,'_Unmixed.tif'];
warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');

% ch1=TIFFStack([filebase,'2.tif']);
% ch2=TIFFStack([filebase,'3.tif']);
% ch3=TIFFStack([filebase,'4.tif']);


warning('off','all'); %Turn off annoying warning messages due to the weird ways imageJ and other programs saves tiff stacks

inputStack=TIFFStack(fullfile(folder,file));
if strcmp(getDataClass(inputStack),'uint16')
   disp('YOU ARE READING AN UNSIGNED INT FILE! MAKE SURE YOU ARE USING RAW DATA!');
   return;
end
ch1=inputStack(:,:,1:4:end);%4 channels so take every 4th image in stack for each channel
ch2=inputStack(:,:,2:4:end);
ch3=inputStack(:,:,3:4:end);
warning('on','all');


to=size(ch1,3);
num_images=to;
nx=size(ch1,1);
ny=size(ch1,2);
nz=to;

if any(size(ch1)~= size(ch2)) | any(size(ch1)~= size(ch3))
    disp(['The size of the selected image stacks do not match']);
    return;
end
firstrun=1;
for i=1:to
    smoothOn=1;   %Change to zero here to not do smoothing
    RGB=unmix_basic_RGBout(ch1,ch2,ch3,m,i,smoothOn);
    RGB=RGB(:,:,RGBreorder);
    %Makes output tiff stacks 
    if firstrun
        t = Tiff(fileout, 'w');
    else
        t = Tiff(fileout, 'a');
        %         info = imfinfo(fileout);
        %         num_images = numel(info);
    end
    tagstruct.ImageLength = (size(RGB, 1));
    tagstruct.ImageWidth = (size(RGB, 2));
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    %  tagstruct.ColorMap=(colormap(gray(2^16)));
    tagstruct.BitsPerSample = (16);
    tagstruct.SamplesPerPixel = (1);
    %   tagstruct.Compression = Tiff.Compression.None;
    tagstruct.RowsPerStrip=(size(RGB,1));
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.SubFileType=(0);
    
    %ImageDescription=sprintf(['ImageJ=1.51p\n', 'images=',num2str(images),  '\nchannels=3\n', 'slices=',num2str(num_images), '\nhyperstack=true\n', 'mode=composite\n',  'loop=false\n',  'min=3.0\n', 'max=15.0\n\0']); %change max here if you want. Can try deleting as well. 
    ImageDescription=sprintf(['ImageJ=1.51p\n', 'images=',num2str(num_images),  '\nchannels=3\n', 'slices=',num2str(num_images), '\nhyperstack=true\n', 'mode=composite\n',  'loop=false\n\0']); 
    tagstruct.ImageDescription=ImageDescription;
    

   for ch=1:3
            if firstrun                
                imwrite(uint16(RGB(:,:,ch)),fileout);
                t = Tiff(fileout, 'a');
                firstrun=0;
                images=1;
            else
                images=images+1;
                imwrite( uint16(RGB(:,:,ch)),fileout,'WriteMode','append');   
            end
   end
    
  disp(['Finished file number: ',num2str(i)])
end
        for idf=1:images
            setDirectory(t,idf);
            setTag(t,'ImageDescription',ImageDescription);
            rewriteDirectory(t);
        end 
t.close();
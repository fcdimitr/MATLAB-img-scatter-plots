function imgScatter3(Y, I, mask, imgW, imgH, az, el)
% IMGSCATTER3 - 3-D Scatter plot with images
%   
% SYNTAX
%
%   IMGSCATTER( YDATA, IMG )
%   IMGSCATTER( YDATA, IMG, MASK )
%   IMGSCATTER( YDATA, IMG, MASK, IMGW, IMGH )
%   IMGSCATTER( YDATA, IMG, MASK, IMGW, IMGH, AZ, EL )
%
% INPUT
%
%   YDATA       3-D points for scatter plot             [n-by-3]
%   IMG         Images for each point                   [p-by-r-by-n]
%               If it's a color image, it should have size [p-by-r-by-c-by-n]
%               c is the color channel. And the IMG 
%               shoud be in uint8 format instead of double
% 
% OPTIONAL
% 
%   MASK        Mask to plot subset of image            [n-by-1]
%               {default: ones(n,1)}
%   IMGW        Width of each image                     [scalar]
%               {default: 0.05}
%   IMGH        Height of each image                    [scalar]
%               {default: 0.05}
%   AZ          Azimuth of initial rotation             [scalar]
%               {default: 150}
%   EL          Elevation of initial rotation           [scalar]
%               {default: 20}
%
% DESCRIPTION
%
%   IMGSCATTER( YDATA, IMG ) plots the 3D points given in matrix
%   YDATA with the corresponding images in matrix IMG.
%
% See also      scatter
%
  
  if ~exist('mask', 'var') || isempty(mask)
    mask = ones(length(Y), 1);
  end
  
  if ~exist('imgW', 'var') || isempty(imgW)
    imgW = 0.1;
  end
  
  if ~exist('imgH', 'var') || isempty(imgH)
    imgH = 0.1;
  end
  
  if ~exist('az', 'var') || isempty(az)
    az = 150;
  end
  
  if ~exist('el', 'var') || isempty(el)
    el = 20;
  end
  
  % clear persistent variables  
  clear setupImgRotation
  
  
  n = size(Y, 1);
  figure;

  scatter3(Y(:,1), Y(:,2), Y(:,3),'.');
  
  view([az el])
  axis equal tight
  
  hold on
  
  s = cell(sum(mask),2);
  
  for i = 1:n
    
    if mask(i) == 1
      im = I(:,:,i);
      if length(size(I))==3
         im = I(:,:,i);
         im = im';
         colormap gray;
      elseif length(size(I))==4
         im = I(:,:,:,i);
         im = permute(im, [2,1,3]);
      end
      [imX,imY] = meshgrid( ...
          linspace(- imgW/2, imgW/2, size(im, 1) ) + Y(i,1), ...
          linspace(- imgH/2, imgH/2, size(im, 2) ) + Y(i,2) );
      
      
      imZ = Y(i,3) * ones( size(imX) );
      
      s{i,1} = surf(imX,imY,imZ,im);
      s{i,2} = Y(i,:);
      s{i,1}.EdgeColor = 'none';
    end
    
  end % for i = 1:n
  
  az_prev = [];
  el_prev = [];
  
  setupImgRotation()
  
  h = rotate3d;
  h.ActionPostCallback = @mycallback;
  
  function setupImgRotation()
        
    if ~isempty(az_prev) && ~isempty(el_prev)
      for ii = 1:length( s )
        rotate(s{ii,1}, -[cosd(az_prev) sind(az_prev) 0], 90-el_prev, s{ii,2} );
        rotate(s{ii,1}, -[0 0 -1], 90-az_prev, s{ii,2} );
      end
    end
    
    az_prev = az;
    el_prev = el;
    
    for ii = 1:length( s )
      rotate(s{ii,1}, [0 0 -1], 90-az, s{ii,2} );
      rotate(s{ii,1}, [cosd(az) sind(az) 0], 90-el, s{ii,2} );
    end

  end
  
  function mycallback(~,evd)
  % If the tag of the object is 'DoNotIgnore', then return true
    
    [newView] = round(evd.Axes.View);
    az = newView(1);
    el = newView(2);
    
    setupImgRotation();
    
  end
  
end






%%------------------------------------------------------------
%
% AUTHORS
%
%   Kostas Mylonakis                        mylonakk@auth.gr
%   Dimitris Floros                         fcdimitr@auth.gr
%
% VERSION
%
%   1.2 - May 25, 2017
%
% CHANGELOG
% 
%   1.2 (May 25, 2017) - Dimitris
%       * added mask to show subset of images
%   1.1 (May 25, 2017) - Dimitris
%       * images follow rotation
%   1.0 (May 25, 2017) - Dimitris
%       * simpler rotation technique
%   0.1 (May 24, 2017) - Dimitris
%       * initial implementation
%
% ------------------------------------------------------------


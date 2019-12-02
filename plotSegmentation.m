function plotSegmentation(im, pred, gt)
% Plot a 2D segmentation with the image, prediction and ground truth masks

% Parameters
gtColor = [0 0 255];
predColor = [255 0 0];
opacity = 0.5;

% Convert the image to RGB
imColor = zeros([size(im) 3]);
for c = 1 : size(imColor, 3)
   imColor(:, :, c) = im; 
end

% Add in the masks
rendered = addBorderOverlay(imColor, gt, gtColor);
rendered = addBorderOverlay(rendered, pred, predColor);

% Plot
imshow(rendered)

end

function overlaid = addBorderOverlay(im, mask, maskColor)
% Like addOverlay, but opaque border
   
opacity = 1.0;

maskBorder = bwperim(mask);
overlaid = addOverlay(im, maskBorder, maskColor, opacity);

end

function overlaid = addOverlay(im, mask, maskColor, opacity)

    % Apply the blend
    overlaid = zeros(size(im));
    for c = 1 : size(im, 3)
        imChannel = im(:, :, c);
        opacityColor = maskColor(c) * opacity;
        overlayChannel = imChannel;
        overlayChannel(mask) = overlayChannel(mask) * (1 - opacity) + opacityColor;
        overlaid(:, :, c) = overlayChannel;
    end
end
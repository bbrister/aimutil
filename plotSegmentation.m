function rendered = plotSegmentation(im, pred, gt)
% Plot a 2D segmentation with the image, prediction and ground truth masks

% Parameters
gtColor = [5 231 252] / 255;
predColor = [252 41 22] / 255;

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
   
% Avoid NaNs if empty
if ~any(mask(:))
    overlaid = im;
    return
end

opacity = 0.9;
aaSigma = 1.25;

% Get the border
maskBorder = bwperim(mask);

% Apply anti-aliasing and opacity
maskAA = imgaussfilt(single(maskBorder), aaSigma);
maskOpacity = maskAA * opacity / max(maskAA(:));

overlaid = addOverlay(im, maskOpacity, maskColor);

end

function overlaid = addOverlay(im, mask, maskColor)
% Uses a mask with opacity in [0, 1]

    % Apply the blend
    overlaid = zeros(size(im));
    for c = 1 : size(im, 3)
        imChannel = im(:, :, c);
        overlaid(:, :, c) = imChannel .* (1 - mask) + mask * maskColor(c);
    end
end
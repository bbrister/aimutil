function points = aimGetPoints(aimName)
%aimGetPoints Return an [mx2] vector of the points demarcing an AIM
%annotation.

% Verify inputs
if (nargin < 1 || isempty(aimName))
    error('aimName not specified')
end

% Add jjvector to the path
addpath(jjPath());

% Set up the XML parser
xmlDoc = parseXML(aimName);
baseFilter = {
    'imageAnnotations'
    'ImageAnnotation'
    'markupEntityCollection'
    'MarkupEntity'
    };
xyFilter = [
    baseFilter
    {
    'geometricShapeCollection'
    'GeometricShape'
    'spatialCoordinateCollection'
    'SpatialCoordinate'
    'twoDimensionSpatialCoordinateCollection'
    'TwoDimensionSpatialCoordinate'
    }
    ];

% Look for attributes 'x' and 'y'
x = parseDoc(xmlDoc, xyFilter, 'x', false);
y = parseDoc(xmlDoc, xyFilter, 'y', false);

% Look for classes named 'x' and 'y' with attribute 'value'
x = [x parseDoc(xmlDoc, [xyFilter; {'x'}], 'value', false)];
y = [y parseDoc(xmlDoc, [xyFilter; {'y'}], 'value', false)];

% Get the slice index
z = parseDoc(xmlDoc, [baseFilter; {'referencedFrameNumber'}], 'value', 0);

% Check dimensions
assert(all(size(x) == size(y)));
if isscalar(z)
    z = repmat(z, size(x));
end
points = [x y z];

% Restore the path
rmpath(jjPath());

end
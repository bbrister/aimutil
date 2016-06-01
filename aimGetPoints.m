function points = aimGetPoints(aimName)
%aimGetPoints Return an [mx2] vector of the points demarcing an AIM
%annotation.

% Verify inputs
if (nargin < 1 || isempty(aimName))
    error('aimName not specified')
end

% Add jjvector to the path
addpath(jjPath());

% Get the annotation coordinates (from jjvector)
xmlDoc = parseXML(aimName);
xml_filter{1} = 'geometricShapeCollection';
xml_filter{2} = 'GeometricShape';
xml_filter{3} = 'spatialCoordinateCollection';
xml_filter{4} = 'SpatialCoordinate';
x = parseDoc(xmlDoc, xml_filter, 'x', 0);
y = parseDoc(xmlDoc, xml_filter, 'y', 0);
assert(all(size(x) == size(y)));
points = [x y];

% Restore the path
rmpath(jjPath());

end
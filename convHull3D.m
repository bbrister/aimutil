function hull = convHull3D(bw)
% Take a convex hull of a 3D mask

% Get the convex hull
[I, J, K] = ind2sub(size(bw), find(bw));
hullTri = convhull(I, J, K, 'simplify', true);

% Convert the convex hull to a Delaunay triangulation
ptsMat = [I, J, K];
triMat = zeros(size(hullTri));
for k = 1 : 3
   triMat(:, k) = ptsMat(hullTri(:, k), k); 
end
clear ptsMat I J K
dt = delaunayTriangulation(triMat);

% Use the Delaunay triangulation to generate a mask for the convex hull
siz = size(bw);
[I, J, K] = ndgrid(1 : siz(1), 1 : siz(2), 1 : siz(3));
hull = ~isnan(pointLocation(dt, I(:), J(:), K(:)));
hull = reshape(hull, siz);

end
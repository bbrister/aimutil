function H=VisualizeBoundSphere(X,R,C)
% Visualize a point cloud (or a triangular surface mesh) and its bounding
% sphere.
%
%   - X     : M-by-3 list of point coordinates or a triangular surface mesh
%             specified as a TriRep object.
%   - R     : radius of the sphere.
%   - C     : 1-by-3 vector specifying the centroid of the sphere.
%   - H     : 1-by-6 vector containing handles for the following objects: 
%               H(1)    : handle of the point cloud/mesh 
%               H(2)    : handle for the sphere
%               H(3:5)  : handles for the great circles 
%               H(6)    : handle for the light used to illuminate the scene 
%
% AUTHOR: Anton Semechko (a.semechko@gmail.com)
% DATE: Dec.2014
%

if nargin<2 || isempty(R) || isempty(C)
    [R,C]=ExactMinBoundSphere3D(X);
end

% Generate a spherical mesh
tr=SubdivideSphericalMesh(IcosahedronMesh,4);
tr=TriRep(tr.Triangulation,bsxfun(@plus,R*tr.X,C));

% Construct great circles 
t=linspace(0,2*pi,1E3);
x=R*cos(t);
y=R*sin(t);

[GC1,GC2,GC3]=deal(zeros(1E3,3));

GC1(:,1)=x; GC1(:,2)=y; % xy-plane
GC2(:,1)=y; GC2(:,3)=x; % zx-plane
GC3(:,2)=x; GC3(:,3)=y; % yz-plane

GC1=bsxfun(@plus,GC1,C);
GC2=bsxfun(@plus,GC2,C);
GC3=bsxfun(@plus,GC3,C);

% Visualize the point cloud/mesh
H=zeros(1,6);
figure('color','w')
if strcmpi(class(X),'TriRep')
    H(1)=trimesh(X);
    set(H(1),'EdgeColor','none','FaceColor','g')
else
    H(1)=plot3(X(:,1),X(:,2),X(:,3),'.k','MarkerSize',20);
end
axis equal off
hold on

% Visualize the sphere and the great circles
H(2)=trimesh(tr);
set(H(2),'EdgeColor','none','FaceColor','r','FaceAlpha',0.5)
H(3)=plot3(GC1(:,1),GC1(:,2),GC1(:,3),'-k','LineWidth',2);
H(4)=plot3(GC2(:,1),GC2(:,2),GC2(:,3),'-k','LineWidth',2);
H(5)=plot3(GC3(:,1),GC3(:,2),GC3(:,3),'-k','LineWidth',2);
axis tight vis3d

% Add some lighting and we are done
H(6)=light;
lighting phong


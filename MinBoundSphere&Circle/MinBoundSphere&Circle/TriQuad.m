function TR=TriQuad(TR,W)
% Subdivide triangular mesh using generalized triangular quadrisection. 
% Triangular quadrisection is a linear subdivision procedure which inserts 
% new vertices into the input mesh at the edge midpoints thereby producing
% four new faces for every face of the original mesh. Illustration of this 
% operation is provided below:
% 
%                     x3                        x3
%                    /  \      subdivision     /  \
%                   /    \         -->        v3__v2
%                  /      \                  / \  / \
%                x1________x2              x1___v1___x2
%
%                   Original vertices:    x1, x2, x3
%                   New vertices:         v1, v2, v3
% 
% In case of generalized triangular quadrisection, the positions of the 
% newly inserted vertices do not necessarily have to correspond to the 
% edge midpoints, and could be varied by assigning weights to the 
% vertices of the original mesh. For example, let xi and xj be two vertices
% connected by an edge, and suppose that Wi and Wj are the 
% corresponding vertex weights. The position of the new point on the edge 
% (xi,xj) would be defined as (Wi*xi+Wj*xj)/(Wi+Wj). Note that in order to
% avoid degeneracies and self intersections, all weights must be positive
% real numbers greater than zero.
%
% INPUT ARGUMENTS:
%   - TR   : input mesh. TR can be specified as a TriRep object or a cell,
%            such that TR={Tri X}, where X is the list of vertex 
%            co-ordinates and Tri is the list of faces.
%   - W    : optional input argument. N-by-1 array of NON-ZERO, POSITIVE 
%            vertex weights used to adjust positions of the new vertices,
%            where N is the total number of the original mesh vertices. 
%
% OUTPUT:
%   - TR  : subdivided mesh. Same format as the input.
%
% AUTHOR: Anton Semechko (a.semechko@gmail.com)
% DATE: May.2012
%

% Get the list of vertex co-ordinates and list of faces
if strcmp(class(TR),'TriRep')
    X=TR.X;
    Tri=TR.Triangulation;
elseif iscell(TR) && numel(TR)==2

    Tri=TR{1};
    X=TR{2};
        
    if max(Tri(:))~=size(X,1) || size(Tri,2)~=3 || ~isequal(round(Tri(1,:)),Tri(1,:))
        error('Invalid entry for the list of faces')
    end
    
else
    error('Unrecognised input format')
end
    
% Check vertex weights
flag=false;
if nargin<2 || isempty(W), flag=true; end

if ~flag && (numel(W)~=size(X,1) || sum(W<=eps))
    error('W must be a N-by-1 array with non-negative entries, where N is the # of mesh vertices')
end
if ~flag, W=W(:)+eps; end

Nx=size(X,1);   % # of vertices
Nt=size(Tri,1); % # of faces

% Compute new vertex positions
if ~flag
    w=bsxfun(@rdivide,[W(Tri(:,1)),W(Tri(:,2))],W(Tri(:,1))+W(Tri(:,2)));
    V1=bsxfun(@times,X(Tri(:,1),:),w(:,1))+bsxfun(@times,X(Tri(:,2),:),w(:,2));
else
    V1=(X(Tri(:,1),:)+X(Tri(:,2),:))/2;
end

if ~flag
    w=bsxfun(@rdivide,[W(Tri(:,2)),W(Tri(:,3))],W(Tri(:,2))+W(Tri(:,3)));
    V2=bsxfun(@times,X(Tri(:,2),:),w(:,1))+bsxfun(@times,X(Tri(:,3),:),w(:,2));
else
    V2=(X(Tri(:,2),:)+X(Tri(:,3),:))/2;
end

if ~flag
    w=bsxfun(@rdivide,[W(Tri(:,3)),W(Tri(:,1))],W(Tri(:,3))+W(Tri(:,1)));
    V3=bsxfun(@times,X(Tri(:,3),:),w(:,1))+bsxfun(@times,X(Tri(:,1),:),w(:,2));
else
    V3=(X(Tri(:,3),:)+X(Tri(:,1),:))/2;
end

V=[V1;V2;V3];

% Remove repeating vertices 
[V,~,idx]=unique(V,'rows','stable'); % setOrder='stable' ensures that identical results (in terms of face connectivity) will be obtained for meshes with same topology


% Assign indices to the new triangle vertices
V1= Nx + idx(1:Nt);
V2= Nx + idx((Nt+1):2*Nt);
V3= Nx + idx((2*Nt+1):3*Nt);
clear idx

% Define new faces
T1= [Tri(:,1) V1 V3];
T2= [Tri(:,2) V2 V1];
T3= [Tri(:,3) V3 V2];
T4= [V1       V2 V3];
clear V1 V2 V3

T1=permute(T1,[3 1 2]);
T2=permute(T2,[3 1 2]);
T3=permute(T3,[3 1 2]);
T4=permute(T4,[3 1 2]);

Tri=cat(1,T1,T2,T3,T4);
Tri=reshape(Tri,[],3,1);

% New mesh
X=[X;V]; 
if strcmp(class(TR),'TriRep')
    TR=TriRep(Tri,X);
else
    TR={Tri,X};
end


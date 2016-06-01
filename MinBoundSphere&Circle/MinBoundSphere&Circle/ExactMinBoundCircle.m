function [R,C,Xb]=ExactMinBoundCircle(X)
% Compute exact minimum bounding circle of a 2D point cloud using Welzl's 
% algorithm. 
%
%   - X     : M-by-2 list of point co-ordinates, where M is the total
%             number of points.
%   - R     : radius of the circle.
%   - C     : 1-by-2 vector specifying the centroid of the circle.
%   - Xb    : subset of X, listing K-by-2 list of point coordinates from 
%             which R and C were computed. See function titled 
%             'FitCirc2Points' for more info.
%
% REREFERENCES:
% [1] Welzl, E. (1991), 'Smallest enclosing disks (balls and ellipsoids)',
%     Lecture Notes in Computer Science, Vol. 555, pp. 359-370
%
% AUTHOR: Anton Semechko (a.semechko@gmail.com)
% DATE: Dec.2014
%


if isobject(X), X=X.X; end
if size(X,2)~=2
    error('This function only works for 2D data')
end
if sum(isnan(X(:)) | isinf(X(:)))>0
    error('Point data contains NaN or Inf entries. Remove them and try again.')
end

% Get the convex hull of the point set
F=convhulln(X);
F=unique(F(:));
X=X(F,:);

% Randomly permute the point set
idx=randperm(size(X,1));
X=X(idx(:),:);

% Get the minimum bounding circle
if size(X,1)<=3
    [R,C]=FitCirc2Points(X); 
    Xb=X;
    return
end

if size(X,1)<1E3
    try
        
        % Center and radius of the circle
        [R,C]=B_MinCircle(X,[]);
        
        % Coordiantes of the points used to compute parameters of the 
        % minimum bounding circle
        D=sum(bsxfun(@minus,X,C).^2,2);
        [D,idx]=sort(abs(D-R^2));
        Xb=X(idx(1:4),:);
        D=D(1:4);
        Xb=Xb(D<1E-6,:);
        [~,idx]=sort(Xb(:,1));
        Xb=Xb(idx,:);
        return
    catch
    end
end
    
% If we got to this point, then the recursion depth limit was reached. So 
% need to break-up the the data into smaller sets and then recombine the 
% results.
M=size(X,1);
dM=min(floor(M/4),300);
res=mod(M,dM);
n=ceil(M/dM);  
idx=dM*ones(1,n);
if res>0
    idx(end)=res;
end
 
if res<=0.25*dM 
    idx(n-1)=idx(n-1)+idx(n);
    idx(n)=[];
    n=n-1;
end

X=mat2cell(X,idx,2);
Xb=[];
for i=1:n
    
    % Center and radius of the circle
    [R,C,Xi]=B_MinCircle([Xb;X{i}],[]);    
    
    % 40 points closest to the circle
    if i<1
        D=abs(sum(bsxfun(@minus,Xi,C).^2,2)-R^2);
    else
        D=abs(sqrt(sum(bsxfun(@minus,Xi,C).^2,2))-R);
    end
    [D,idx]=sort(D);
    Xb=Xi(idx(1:40),:);
    
end
D=D(1:3);
Xb=Xb(D/R*100<1E-3,:);
[~,idx]=sort(Xb(:,1));
Xb=Xb(idx,:);


    function [R,C,P]=B_MinCircle(P,B)
        
    if size(B,1)==3 || isempty(P)
        [R,C]=FitCircle2Points(B); % fit circle to boundary points
        return
    end
    
    % Remove the last (i.e., end) point, p, from the list
    P_new=P;
    P_new(end,:)=[];
    p=P(end,:);
        
    % Check if p is on or inside the bounding circle. If not, it must be
    % part of the new boundary.
    [R,C,P_new]=B_MinCircle(P_new,B); 
    if isnan(R) || isinf(R) || R<=eps
        chk=true;
    else
        chk=norm(p-C)>(R+eps);
    end
    
    if chk
        B=[p;B];
        [R,C]=B_MinCircle(P_new,B);
        P=[p;P_new];
    end
        
    end


end


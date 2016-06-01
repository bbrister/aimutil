function MinBoundSphereDemo

% Load sample triangular surface meshes saved as TriRep objects
Data=load('Sample TriRep Meshes');
Fields=fieldnames(Data);

% Compute exact minimum bounding spheres using Wezlz's agorithm for the 
% sample meshes and visualize the meshes along with the spehres. Also 
% compute approximate minimum bounding spheres usign Ritter's algorith for
% later comparison.
N=numel(Fields);
R=zeros(N,2);
for i=1:N
    
    % Get i-th sample mesh
    TR=getfield(Data,Fields{i});
    
    % Find the exact bounding sphere
    [R(i,1),C]=ExactMinBoundSphere3D(TR.X);
    
    % Visualize the mesh and its bounding minimum sphere
    [~]=VisualizeBoundSphere(TR,R(i,1),C);
    set(gcf,'Name',Fields{i})
    
    % Get the radius of the approximate minimum bounding sphere
    R(i,2)=ApproxMinBoundSphereND(TR.X);
    
end

% Compare the radii of the spheres produced by the Ritter's algorithm,
% which produces an approximate solution, and Welzl's algorithm, which 
% produces an exact solution
fprintf('\nApproximate (R_ap) vs exact (R_ex) min bounding sphere radii\n\n')
fprintf('==============================================================\n')
fprintf('%-16s%-14s%-14s%-14s\n','Object','R_ap', 'R_ex','Relative Diff.(%)')
fprintf('--------------------------------------------------------------\n')
for i=1:N
    fprintf('%-16s%-14.4f%-14.4f%-14.4f\n',Fields{i},R(i,2),R(i,1),(R(i,2)-R(i,1))/R(i,1)*100)
end
fprintf('--------------------------------------------------------------\n')









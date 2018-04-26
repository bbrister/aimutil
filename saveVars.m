function saveVars(matName, varargin)
% Saves matlab variables to the specified .mat file, under the name used
% in the caller. This allows 'save' to be used in a parfor loop.

numVars = length(varargin);
varNames = cell(numVars, 1);
for i = 1 : length(varargin)
    varName = inputname(i + 1);
    eval([varName ' = varargin{i};'])
    varNames{i} = varName;
end
save(matName, varNames{:})

end
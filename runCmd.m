function status = runCmd(cmd)
%runCmd helper function to run a command in the default system environment,
% without Matlab's changes to the environment variables. Also makes sure to
% run this as 'user'

% Strip the LD_LIBRARY_PATH environment variable of Matlab directories
ldPathVar = 'LD_LIBRARY_PATH';
oldLdPath = getenv(ldPathVar);
newLdPath = regexprep(oldLdPath, '[^:]*MATLAB[^:]*:*', '', 'ignorecase');
setenv(ldPathVar, newLdPath);

% Run the command
status = system(cmd);

% Return the environment to its previous state
setenv(ldPathVar, oldLdPath);

end